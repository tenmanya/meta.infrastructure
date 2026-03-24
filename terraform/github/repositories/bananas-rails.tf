resource "github_repository" "bananas-rails" {
  name        = "bananas.rails"
  description = "Bananas Rails apps. This environment specific but currently only production."
  topics      = ["rails"]

  visibility = "public"

  has_issues   = false
  has_projects = false
  has_wiki     = false

  auto_init              = true
  is_template            = false
  delete_branch_on_merge = true

  vulnerability_alerts = false
}

resource "github_branch" "bananas-rails-main" {
  repository = github_repository.bananas-rails.name
  branch     = "main"
}

resource "github_branch_default" "bananas-rails-default" {
  repository = github_repository.bananas-rails.name
  branch     = github_branch.bananas-rails-main.branch
}

resource "github_branch_protection" "bananas-rails-default" {
  repository_id = github_repository.bananas-rails.name

  pattern          = "main"
  enforce_admins   = false
  allows_deletions = true
}


## bananas ECR push

resource "github_repository_environment" "bananas-rails-ecr-push" {
  repository  = github_repository.bananas-rails.name
  environment = "bananas-ecr-push"

  reviewers {
    teams = [data.github_user.jtsaito.id]
  }

  lifecycle {
    # known provider bug, manage manually
    ignore_changes = [reviewers]
  }
}

resource "github_actions_environment_variable" "bananas-rails-ecr-push-aws-iam-role-arn-bananas-deploy" {
  repository  = github_repository.bananas-rails.name
  environment = github_repository_environment.bananas-rails-ecr-push.environment

  variable_name = "AWS_IAM_ROLE_ARN_BANANAS_DEPLOY"
  value         = aws_iam_role.bananas-deploy.arn
}

resource "github_actions_environment_variable" "bananas-rails-ecr-push-aws-region-bananas-deploy" {
  repository  = github_repository.bananas-rails.name
  environment = github_repository_environment.bananas-rails-ecr-push.environment

  variable_name = "AWS_IAM_REGION_BANANAS_DEPLOY"
  value         = "eu-west-1" # should be derived from ECR
}

resource "github_actions_environment_variable" "bananas-rails-ecr-push-ecr-repository-bananas" {
  repository  = github_repository.bananas-rails.name
  environment = github_repository_environment.bananas-rails-ecr-push.environment

  variable_name = "AWS_ECR_REPOSITORY_BANANAS"
  value         = module.ecr-repository-bananas.repository.name
}
