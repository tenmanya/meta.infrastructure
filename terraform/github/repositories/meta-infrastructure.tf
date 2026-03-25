import {
  to = github_repository.meta-infrastructure
  id = "meta.infrastructure"
}

resource "github_repository" "meta-infrastructure" {
  name        = "meta.infrastructure"
  description = "Infrastructure not specific to enviroments, shared accross reositories (most GitHub resources)"
  topics      = ["terraform"]

  visibility = "public"

  has_issues   = false
  has_projects = false
  has_wiki     = false

  auto_init              = true
  is_template            = false
  delete_branch_on_merge = true

  vulnerability_alerts = false
}

resource "github_branch" "meta-infrastructure-main" {
  repository = github_repository.meta-infrastructure.name
  branch     = "main"
}

resource "github_branch_default" "meta-infrastructure-default" {
  repository = github_repository.meta-infrastructure.name
  branch     = github_branch.meta-infrastructure-main.branch
}

resource "github_branch_protection" "meta-infrastructure-default" {
  repository_id = github_repository.meta-infrastructure.name

  pattern          = "main"
  enforce_admins   = false
  allows_deletions = true
}
