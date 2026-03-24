resource "aws_s3_bucket" "cloud-nova-corp-terraform" {
  bucket = "cloud-nova-corp-terraform"

  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud-nova-corp-terraform" {
  bucket = aws_s3_bucket.cloud-nova-corp-terraform.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloud-nova-corp-terraform" {
  bucket = aws_s3_bucket.cloud-nova-corp-terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloud-nova-corp-terraform" {
  bucket = aws_s3_bucket.cloud-nova-corp-terraform.bucket

  block_public_acls  = true
  ignore_public_acls = true

  block_public_policy     = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "cloud-nova-corp-terraform" {
  bucket = aws_s3_bucket.cloud-nova-corp-terraform.bucket

  policy = data.aws_iam_policy_document.s3-cloud-nova-corp-terraform-cross-account-user-access.json
}

# allow terraform user to read remote state state files
data "aws_iam_policy_document" "s3-cloud-nova-corp-terraform-cross-account-user-access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::205899621967:user/cloud-nova-corp-terraform"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloud-nova-corp-terraform.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.cloud-nova-corp-terraform.bucket}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3-bucket-cloud-nova-corp-terraform-fullaccess" {
  statement {
    actions   = ["s3:List*", "s3:Get*"]
    resources = [aws_s3_bucket.cloud-nova-corp-terraform.arn]
  }

  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.cloud-nova-corp-terraform.arn}/*"]
  }
}

output "s3-bucket-cloud-nova-corp-terraform" {
  value = aws_s3_bucket.cloud-nova-corp-terraform
}

output "iam-policy-document-s3-bucket-cloud-nova-corp-terraform-fullaccess" {
  value = data.aws_iam_policy_document.s3-bucket-cloud-nova-corp-terraform-fullaccess.json
}
