locals {
  rules = concat(
    [
      for keep_image_tag in var.keep_image_tags :

      {
        description = "Keep image tagged with ${keep_image_tag}."

        selection = {
          tagStatus = "tagged"

          tagPrefixList = [keep_image_tag]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }

        action = {
          type = "expire"
        }
      }
    ],
    [
      {
        description = "Keep 9000 tagged images that are not tagged with an environment."

        selection = {
          tagStatus = "tagged"

          # If you specify multiple tags, images with just one matching tag are selected.
          # https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lp_tag_prefix_list
          tagPrefixList = ["sha-"]
          countType     = "imageCountMoreThan"
          countNumber   = 9000
        }

        action = {
          type = "expire"
        }
      },
    ],
    [
      {
        description = "Expire untagged images older than 1 day."

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }

        action = {
          type = "expire"
        }
      },
    ],
  )

  policy = {
    rules = [
      for index in range(length(local.rules)) :

      merge(
        local.rules[index],
        {
          rulePriority = index + 1
        }
      )
    ]
  }

  ecs_root_user_arns = [for id in var.ecs_account_ids : "arn:aws:iam::${id}:root"]

  lambda_arns = [for id in var.lambda_account_ids : "arn:aws:lambda:${data.aws_region.current.region}:${id}:function:*"]

  cross_account_lambda_account_root_ids = [
    for id in setsubtract(var.lambda_account_ids, [data.aws_caller_identity.current.account_id]) :
    "arn:aws:iam::${id}:root"
  ]

  ecr_repository_policy_statements = [
    length(var.ecs_account_ids) > 0 ? {
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
      ]
      principals = [{
        type        = "AWS"
        identifiers = local.ecs_root_user_arns
      }]
    } : null,
    length(var.lambda_account_ids) > 0 ? {
      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      principals = [{
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }]
      conditions = [{
        test     = "StringLike"
        variable = "aws:sourceArn"
        values   = local.lambda_arns
      }]
    } : null,
    length(local.cross_account_lambda_account_root_ids) > 0 ?
    {
      # https://repost.aws/knowledge-center/lambda-ecr-image
      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      principals = [{
        type        = "AWS"
        identifiers = local.cross_account_lambda_account_root_ids
      }]
    } : null,
  ]

  stmts = [for statement in local.ecr_repository_policy_statements : statement if statement != null]
}

resource "aws_ecr_repository" "repository" {
  name = var.name

  force_delete = var.force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.default_tags, var.ecr_repository_tags)
}

resource "aws_ecr_repository_policy" "policy" {
  count = length(local.stmts) > 0 ? 1 : 0

  repository = aws_ecr_repository.repository.name
  policy     = data.aws_iam_policy_document.ecr_repository_policy[count.index].json
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repository.name

  policy = jsonencode(local.policy)
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecr-repository-pull" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]

    resources = [
      aws_ecr_repository.repository.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecr-repository-push" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      aws_ecr_repository.repository.arn,
    ]
  }

  # We need read permissions in GitHub Actions in order to be able to:
  #
  # 1. Check whenever an image with a given Commit SHA was already uploaded
  # 2. Possiblility to make use of caching [to be verified]
  #
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]

    resources = [
      aws_ecr_repository.repository.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecr_repository_policy" {
  count = length(local.stmts) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = local.stmts

    content {

      actions = statement.value.actions

      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, {})

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}
