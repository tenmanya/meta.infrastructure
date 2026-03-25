# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Foundational Terraform infrastructure managing shared AWS and GitHub resources for the `cloud-nova-crop` organisation. This is the meta layer — it owns the ECR registry, IAM roles, S3 Terraform state bucket, GitHub repositories, and GitHub Actions OIDC integration used by all other repos.

- **Meta/shared AWS account**: `838650235286`
- **Production AWS account**: `205899621967`
- **GitHub org**: `cloud-nova-crop`

## Terraform Commands

Run from within the `terraform/` directory:

```bash
make plan      # init + plan (default goal)
make apply     # init + apply
make validate  # init + validate
make upgrade   # upgrade provider versions
make clean     # remove generated main.tf
```

The Makefile concatenates all `.tf` files into a single `main.tf` before running Terraform. The generated `main.tf` is gitignored.

- **Backend**: S3 bucket `cloud-nova-corp-terraform`, key `meta.terraform/terraform.tfstate`, region `eu-west-1`
- **Terraform version**: `1.14.7`
- **Providers**: AWS (`~> 6.36.0`) and GitHub (`6.11.1`)

## Architecture

### Multi-account pattern
The AWS provider assumes `arn:aws:iam::838650235286:role/fullaccess` in the meta account. The S3 state bucket grants cross-account access to the production account (`205899621967`).

### GitHub OIDC for CI/CD
`terraform/iam/open_id_connect_provider.tf` sets up GitHub Actions OIDC so workflows can assume AWS roles without long-lived credentials. Trust policy is scoped to `repo:cloud-nova-corp/*`. Two roles are defined:
- `terraform-apply` — used by GitHub Actions to run Terraform in other repos
- `bananas-deploy` — used by GitHub Actions to push Docker images to ECR

### ECR module
`modules/ecr_repository/` is a reusable module that creates an ECR repository with lifecycle policies (keeps `production`/`staging` tagged images indefinitely, expires untagged images after 180 days) and outputs separate IAM policy documents for push and pull.

### GitHub resource management
`terraform/github/` manages repositories, branch protection, GitHub Actions environments, and environment variables (AWS role ARNs, regions, Terraform backend config) for:
- `bananas.rails` — public Rails app repo
- `bananas.terraform` — private Terraform repo

### Locals and tagging
`terraform/_config/locals.tf` defines shared tags (`org = "cloud-nova"`, `environment = "meta"`). Note: the local variable has a typo — `enviroment` (missing an 'n') — match this exactly when referencing it.

### GitHub provider authentication
The GitHub provider token is stored in AWS Secrets Manager (`terraform/secretsmanager/`). It is read at plan/apply time and is managed manually (not rotated by Terraform).
