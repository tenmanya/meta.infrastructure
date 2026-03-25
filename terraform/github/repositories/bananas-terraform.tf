resource "github_repository" "bananas-terraform" {
  name        = "bananas.terraform"
  description = "Bananas Terraform setup. This environment specific but currently only production."
  topics      = ["examples", "terraform"]

  visibility = "public"

  has_issues   = false
  has_projects = false
  has_wiki     = false

  auto_init              = true
  is_template            = false
  delete_branch_on_merge = true

  vulnerability_alerts = false
}

resource "github_branch" "bananas-terraform-main" {
  repository = github_repository.bananas-terraform.name
  branch     = "main"
}

resource "github_branch_default" "bananas-terraform-default" {
  repository = github_repository.bananas-terraform.name
  branch     = github_branch.bananas-terraform-main.branch
}

resource "github_branch_protection" "bananas-terraform-default" {
  repository_id = github_repository.bananas-terraform.name

  pattern          = "main"
  enforce_admins   = false
  allows_deletions = true
}


## repository environment production for Terraform
resource "github_repository_environment" "bananas-terraform-production" {
  repository  = github_repository.bananas-terraform.name
  environment = "production"

  # only available to private repos when using GitHub Enterprise plan :(
  # reviewers {
  #   teams = [data.github_user.jtsaito]
  # }
}

resource "github_actions_environment_variable" "bananas-terraform-production-aws-iam-role-terraform-apply" {
  repository  = github_repository.bananas-terraform.name
  environment = github_repository_environment.bananas-terraform-production.environment

  variable_name = "AWS_IAM_ROLE_TERRAFORM_APPLY"
  value         = aws_iam_role.terraform-apply.arn
}

resource "github_actions_environment_variable" "bananas-terraform-production-environment" {
  repository  = github_repository.bananas-terraform.name
  environment = github_repository_environment.bananas-terraform-production.environment

  variable_name = "ENVIRONMENT"
  value         = "production"
}

resource "github_actions_environment_variable" "bananas-terraform-production-aws-region-terraform-apply" {
  repository  = github_repository.bananas-terraform.name
  environment = github_repository_environment.bananas-terraform-production.environment

  variable_name = "AWS_REGION_TERRAFORM_APPLY"
  value         = data.aws_region.current.region
}

resource "github_actions_environment_variable" "bananas-terraform-production-tf-backend" {
  for_each = {
    BUCKET   = aws_s3_bucket.cloud-nova-corp-terraform.bucket
    REGION   = data.aws_region.current.region
    ROLE_ARN = data.aws_iam_role.fullaccess.arn
  }

  repository  = github_repository.bananas-terraform.name
  environment = github_repository_environment.bananas-terraform-production.environment

  variable_name = "TF_BACKEND_${each.key}"
  value         = each.value
}

resource "github_actions_environment_variable" "bananas-terraform-productin-tf-backend-key" {
  repository  = github_repository.bananas-terraform.name
  environment = github_repository_environment.bananas-terraform-production.environment

  variable_name = "TF_BACKEND_KEY"
  value         = "${github_repository.bananas-terraform.name}/production/terraform.tfstate"
}
