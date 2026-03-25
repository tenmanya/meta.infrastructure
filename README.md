# meta.infrastructure

Foundational AWS and GitHub infrastructure shared across the `cloud-nova-crop` organisation, managed with Terraform.

## What it manages

- **ECR** — Container registry for the Bananas application
- **IAM** — GitHub Actions OIDC provider and roles for CI/CD (`terraform-apply`, `bananas-deploy`)
- **S3** — Terraform state bucket (`cloud-nova-corp-terraform`)
- **Secrets Manager** — GitHub provider token for Terraform
- **GitHub** — Repositories, branch protection, Actions environments and variables for `bananas.rails` and `bananas.terraform`

## AWS accounts

| Account | ID |
|---|---|
| Meta/shared | `838650235286` |
| Production | `205899621967` |
