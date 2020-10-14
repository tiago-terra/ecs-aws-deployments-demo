# IAM User - retrieve user
data "aws_iam_user" "main" {
  user_name = var.user_name
}
# IAM Role - retrieve role
data "aws_iam_role" "main" {
  name = var.role_name
}