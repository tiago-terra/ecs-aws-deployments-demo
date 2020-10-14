provider "aws" {
  region = "eu-west-2"
}

locals {
  policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
  services = [
    "eks.amazonaws.com",
    "cloudwatch.amazonaws.com",
    "codecommit.amazonaws.com",
    "codebuild.amazonaws.com",
    "codepipeline.amazonaws.com",
    "s3.amazonaws.com"
    ]
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = var.tf_bucket

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

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.tf_lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# IAM Operations
resource "aws_iam_user" "main" {
  name = var.service_user_name
  path = "/"
}

resource "aws_iam_user_policy_attachment" "user_attachment" {
  count      = length(local.policies)
  user       = aws_iam_user.main.name
  policy_arn = element(local.policies, count.index)
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
      identifiers = local.services
    }
  }
}

# IAM - Create Role
resource "aws_iam_role" "main" {
  name = var.service_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  count      = length(local.policies)
  role       = aws_iam_role.main.name
  policy_arn = element(local.policies, count.index)
}