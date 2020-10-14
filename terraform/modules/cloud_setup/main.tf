# IAM User - attach public key
resource "aws_iam_user_ssh_key" "main" {
  username   = var.user_name
  encoding   = "SSH"
  public_key = var.public_key
}

# ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = "ecr_${var.project_name}"
  image_tag_mutability = "MUTABLE"
}

# CodeCommit - Create repo
resource "aws_codecommit_repository" "main" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}

resource "random_uuid" "deploy" {}

# Build S3 bucket for CodePipeline artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "artifacts-${random_uuid.deploy.result}"
  acl    = "private"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "null_resource" "set_remote_url" {

  provisioner "local-exec" {
    command = "git remote set-url aws ssh://${aws_iam_user_ssh_key.main.ssh_public_key_id}@${trimprefix(aws_codecommit_repository.main.clone_url_ssh,"ssh://")}"
  }
}