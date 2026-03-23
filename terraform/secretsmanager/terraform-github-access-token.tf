resource "aws_secretsmanager_secret" "terraform_github_access_token" {
  name = "terraform.github_access_token"

  description = <<EOS
Access token used for applying changes with Terraform provider GitHub in the GitHub organization cloud-nova-crop.

The value is managed manually.

The token is a classic personal access token of GitHub user tf with reopsitory read/write scope.
EOS

  tags = local.tags
}
