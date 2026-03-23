variable "default_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Tags which will be attached to all resources.
EOS
}

variable "ecr_repository_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to the ECR repository. Tags in this map will overwrite tags with the same key in `var.default_tags`.
EOS
}

variable "ecs_account_ids" {
  type    = list(string)
  default = []

  description = <<EOS
List of all AWS account IDs which access this ECR repository via ECS tasks.
EOS
}

variable "keep_image_tags" {
  type = list(string)

  description = <<EOS
List of all tags whose images will not be deleted by the lifecycle policy.
EOS
}

variable "name" {
  type = string

  description = <<EOS
Name of ECR repository.
EOS
}

variable "force_delete" {
  type    = bool
  default = false

  description = <<EOS
Whether to force delete the repository when it contains images. If false, Terraform will fail to delete the repository if it contains images.
EOS
}
