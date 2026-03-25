# meta.infrastructure

Foundational AWS and GitHub infrastructure shared across the `cloud-nova-crop` organisation (yes, there is a typo), managed with Terraform.

## Purpose

This repository manages resources that are outside of a specific `staging` or `production` environment.
It manages GitHub repositories, and S3 bucket where all repos store Terraform related data, an ECR repository.
Other repositories manage the `production` and more environments could be added, but the aforementioned resources
are shared by all environments current and future.

Currently, there is only one environment, `production` managing AWS account 205xxxxxxxxx. However, more could be added easily
using the shared infrastructure provided by this repo. 

## What it manages

- **ECR** — Container registry for the Bananas application
- **IAM** — GitHub Actions OIDC provider and roles for CI/CD (`terraform-apply`, `bananas-deploy`)
- **S3** — Terraform state bucket (`cloud-nova-corp-terraform`) used to store Terraform states and lock files, and plan uploaded by CI.
- **Secrets Manager** — GitHub provider token for Terraform
- **GitHub** — Repositories, branch protection, Actions environments and variables for `bananas.rails` and `bananas.terraform`

## AWS accounts

The AWS resources of this repository reside in a separate AWS account 838xxxxxxxxx.

| Account | ID |
|---|---|
| Meta/shared | `838xxxxxxxxx` |
| Production | `205xxxxxxxxx` |
