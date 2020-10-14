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

resource "aws_iam_user_policy_attachment" "test-attach" {
  count      = length(var.policies)
  user       = aws_iam_user.main.name
  policy_arn = element(var.policies, count.index)
}

# IAM Policy - Role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [aws_iam_user.main.arn]
    }
    principals {
      type = "Service"
      identifiers = var.services
    }
  }
}

# IAM - Create Role
resource "aws_iam_role" "main" {
  name = "service_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  count      = length(var.policies)
  role       = aws_iam_role.main.name
  policy_arn = element(var.policies, count.index)
}

# ECR - Create repo
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