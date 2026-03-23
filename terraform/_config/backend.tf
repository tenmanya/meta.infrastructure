terraform {
  backend "s3" {
    bucket       = "cloud-nova-corp-terraform"
    key          = "meta.terraform/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true

    assume_role = {
      role_arn = "arn:aws:iam::838650235286:role/fullaccess"
    }
  }
}
