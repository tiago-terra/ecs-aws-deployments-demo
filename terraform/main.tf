provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

# CodeCommit - Create repo
resource "aws_codecommit_repository" "main" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}

# ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = "nginx_demo"
  image_tag_mutability = "MUTABLE"
}