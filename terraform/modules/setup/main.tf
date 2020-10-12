# Create codecommit repo
resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = var.repo_name
  description     = "Repository ${var.repo_name}"
  default_branch  = "master"
}

# Create iam_role
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild_service_role"
  assume_role_policy = file("./policies/iam_role.json")
}

# Create iam_policy
data "template_file" "policy" {
  template = file("./policies/iam_policy.json")
  vars = {
    codecommit_arn = aws_codecommit_repository.deployment_repo.arn
    codebuild_arn = aws_iam_role.codebuild_role.arn
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${aws_iam_role.codebuild_role.name}_policy"
  role   = aws_iam_role.codebuild_role.name
  policy = data.template_file.policy.rendered
}