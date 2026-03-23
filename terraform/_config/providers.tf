provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::838650235286:role/fullaccess"
  }
}

data "aws_region" "current" {}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::838650235286:role/fullaccess"
  }
}

provider "github" {
  owner = "cloud-nova-crop"

  token = ephemeral.aws_secretsmanager_secret_version.terraform_github_access_token.secret_string
}
