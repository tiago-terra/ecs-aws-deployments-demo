# IAM Operations
resource "aws_iam_user" "main" {
  name = "service_user"
  path = "/"
}

# Add public key to user
resource "aws_iam_user_ssh_key" "main" {
  username   = aws_iam_user.main.name
  encoding   = "SSH"
  public_key = var.public_key
}

# Attach managed policies to user
resource "aws_iam_user_policy_attachment" "main" {
  count      = length(var.policy_arns)
  user       = aws_iam_user.main.name
  policy_arn = element(var.policy_arns, count.index)
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
  principals {
    type = "Service"
    identifiers = [
      "ecr.amazonaws.com",
      "cloudwatch.amazonaws.com",
      "codecommit.amazonaws.com",
      "codebuild.amazonaws.com",
      "codepipeline.amazonaws.com"
      ]
    }
  }
}

# Creates service role
resource "aws_iam_role" "codebuild" {
  name = "codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}

# Create ECR Repo
resource "aws_ecr_repository" "main" {
  name                 = "ecr_${var.project_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# CodeCommit - Create repo
resource "aws_codecommit_repository" "main" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}

resource "null_resource" "set_remote_url" {

  provisioner "local-exec" {
    command = "git remote set-url aws ssh://${aws_iam_user_ssh_key.main.ssh_public_key_id}@${trimprefix(aws_codecommit_repository.main.clone_url_ssh,"ssh://")}"
  }
}