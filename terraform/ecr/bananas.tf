module "ecr-repository-bananas" {
  source = "../modules/ecr_repository"

  name = "bananas"

  keep_image_tags = ["production", "staging"]

  ecs_account_ids = ["205899621967"]

  default_tags = {
    app = "bananas"
  }
}

output "ecr_repository_bananas" {
  value = module.ecr-repository-bananas.repository
}

output "ecr_repository_bananas_iam_policy_document_repository_pull" {
  value = module.ecr-repository-bananas.iam-policy-document-repository.pull
}
