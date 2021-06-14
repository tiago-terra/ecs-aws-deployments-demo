resource "aws_codecommit_repository" "this" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}
