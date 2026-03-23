provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::838650235286:role/fullaccess"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::838650235286:role/fullaccess"
  }
}
