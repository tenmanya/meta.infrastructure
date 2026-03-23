resource "aws_iam_role" "bananas-deploy" {
  name = "bananas-deploy"

  description = <<-EOT
    Grant AWS IAM permissions to deploy Bananas in GitHub Org cloud-nova-corp-terraform using GitHub actions with OIDC perimssions:

    - https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws#configuring-the-role-and-trust-policy
  EOT


  assume_role_policy = data.aws_iam_policy_document.oidc-provider-github-assume-role-with-web-idenity.json

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_role_policy" "bananas-deploy-ecr-repository-bananas-push" {
  role   = aws_iam_role.bananas-deploy.name
  name   = "ecr-repository-bananas-push"
  policy = module.ecr-repository-bananas.iam-policy-document-repository.push
}

output "iam-role-bananas-deploy" {
  value = aws_iam_role.bananas-deploy
}
