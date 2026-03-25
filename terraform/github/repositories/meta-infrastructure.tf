import {
  to = github_repository.meta-infrastructure
  id = "meta.infrastructure"
}

resource "github_repository" "meta-infrastructure" {
  name        = "meta.infrastructure"
  description = "Infrastructure not specific to enviroments, shared accross reositories (most GitHub resources)"
  topics      = ["terraform"]

  visibility = "private"

  has_issues   = false
  has_projects = false
  has_wiki     = false

  auto_init              = true
  is_template            = false
  delete_branch_on_merge = true

  vulnerability_alerts = false
}
