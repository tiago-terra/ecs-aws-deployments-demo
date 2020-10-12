# Code Commit
resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = var.repository_name
  description     = "Repository ${var.repository_name}"
  default_branch = "master"
}