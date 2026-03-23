# initial entry point
data "aws_iam_role" "fullaccess" {
  name = "fullaccess"
}

output "iam-role-fullaccess" {
  value = data.aws_iam_role.fullaccess
}
