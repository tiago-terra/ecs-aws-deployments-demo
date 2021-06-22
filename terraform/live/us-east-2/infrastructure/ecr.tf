resource "aws_ecr_repository" "this" {
  name = local.project_name
  tags = local.tags
}
