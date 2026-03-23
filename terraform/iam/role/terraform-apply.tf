resource "aws_iam_role" "terraform-apply" {
  name = "terraform-apply"

  description = <<-EOT
    Grant AWS IAM permissions to apply Terrafrom functions in GitHub Org cloud-nova-corp GitHub actions with OIDC perimssions:

    - https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws#configuring-the-role-and-trust-policy
  EOT

  assume_role_policy = data.aws_iam_policy_document.oidc-provider-github-assume-role-with-web-idenity.json

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_role_policy" "gh-oidc-cloud-nova-crop-terraform-apply-s3-bucket-cloud-nova-corp-terraform-fullaccess" {
  role   = aws_iam_role.terraform-apply.name
  name   = "s3-bucket-cloud-nova-corp-terraform-fullaccess"
  policy = data.aws_iam_policy_document.s3-bucket-cloud-nova-corp-terraform-fullaccess.json
}

output "iam-role-terraform-apply" {
  value = aws_iam_role.terraform-apply
}
