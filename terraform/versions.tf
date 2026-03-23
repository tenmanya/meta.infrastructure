terraform {
  required_version = "1.14.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36.0"
    }

    github = {
      source  = "integrations/github"
      version = "6.11.1"
    }
  }
}
