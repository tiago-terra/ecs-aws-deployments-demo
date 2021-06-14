data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-2"
}

# ECR Repository
resource "aws_ecr_repository" "this" {
  name = local.project_name
  tags = local.tags
}
