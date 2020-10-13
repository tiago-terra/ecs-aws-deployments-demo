#IAM - Create user
resource "aws_iam_user" "main" {
  name = "service_user"
  path = "/"
}

#IAM - Associate public key
resource "aws_iam_user_ssh_key" "main" {
  username   = aws_iam_user.main.name
  encoding   = "SSH"
  public_key = var.public_key
}

#IAM - Attach policies to user
resource "aws_iam_user_policy_attachment" "main" {
  count      = length(var.policy_arns)
  user       = aws_iam_user.main.name
  policy_arn = element(var.policy_arns, count.index)
}

#IAM - Create policy json
data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
  principals {
    type = "Service"
    identifiers = ["codecommit.amazonaws.com"]
    }
  }
}

#IAM - Associate policy to role
resource "aws_iam_role" "codebuild" {
  name = "codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}

#ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = "deploy_test"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}