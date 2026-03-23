output "iam-policy-document-repository" {
  value = {
    pull = data.aws_iam_policy_document.ecr-repository-pull.json
    push = data.aws_iam_policy_document.ecr-repository-push.json
  }
}

output "repository" {
  value = aws_ecr_repository.repository
}
