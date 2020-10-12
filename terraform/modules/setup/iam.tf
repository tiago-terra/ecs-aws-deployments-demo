data "template_file" "iam_role_template" {
  template = file("policies/iam_service_role.json")
  vars = { service = "codebuild"}
}

# Create an IAM role for CodeBuild to assume
resource "aws_iam_role" "codebuild_iam_role" {
  name = var.codebuild_iam_role_name
  assume_role_policy = file("./policies/iam_codebuild.json")
}

# Create an IAM role policy for CodeBuild to use implicitly
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  name = var.codebuild_iam_role_policy_name
  role = aws_iam_role.codebuild_iam_role.name
  policy = template_file.iam_role_template
}