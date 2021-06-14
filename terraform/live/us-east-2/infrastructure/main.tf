provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

# ECR Repository
resource "aws_ecr_repository" "main" {
  name = local.project_name
  tags = local.tags
}
