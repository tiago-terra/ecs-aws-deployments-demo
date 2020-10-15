# CodeCommit - Create repo
resource "aws_codecommit_repository" "main" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}

# ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = "nginx_ds"
  image_tag_mutability = "MUTABLE"
}

# EKS - Create cluster
resource "aws_eks_cluster" "main" {
  name     = "eks_${var.project_name}"
  role_arn = data.aws_iam_role.main.arn

  vpc_config {
    subnet_ids = [aws_subnet.blue.id, aws_subnet.green.id]
  }
}

# Build S3 bucket for CodePipeline artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "artifacts-${var.project_name}"
  acl    = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}