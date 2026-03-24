resource "aws_iam_role" "terraform-apply" {
  name = "terraform-apply"

  description = <<-EOT
    Grant AWS IAM permissions to apply Terrafrom functions in GitHub Org cloud-nova-corp GitHub actions with OIDC perimssions:

    - https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws#configuring-the-role-and-trust-policy
  EOT

  assume_role_policy = data.aws_iam_policy_document.terraform-apply-assume-role-combined.json

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_role_policy" "gh-oidc-cloud-nova-crop-terraform-apply-s3-bucket-cloud-nova-corp-terraform-fullaccess" {
  role   = aws_iam_role.terraform-apply.name
  name   = "s3-bucket-cloud-nova-corp-terraform-fullaccess"
  policy = data.aws_iam_policy_document.s3-bucket-cloud-nova-corp-terraform-fullaccess.json
}

# allow production account apply role to access bucket
data "aws_iam_policy_document" "cross-account-assume-role-production-fullaccess" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::205899621967:user/cloud-nova-corp-terraform" # apply user
      ]
    }
  }
}

data "aws_iam_policy_document" "terraform-apply-assume-role-combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.oidc-provider-github-assume-role-with-web-idenity.json,
    data.aws_iam_policy_document.cross-account-assume-role-production-fullaccess.json
  ]
}

output "iam-role-terraform-apply" {
  value = aws_iam_role.terraform-apply
}
