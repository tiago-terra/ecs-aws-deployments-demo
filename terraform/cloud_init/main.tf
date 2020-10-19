provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = var.tf_bucket

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
# IAM - Create user
resource "aws_iam_user" "main" {
  name = var.service_user_name
  path = "/"
}

# IAM Policy - role policy
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
  name = var.service_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  force_detach_policies = true
}

# Create assume role trust
data "aws_iam_policy_document" "deploy_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["cloudwatch.amazonaws.com","codebuild.amazonaws.com","eks.amazonaws.com" ]
    }
    principals {
      type = "AWS"
      identifiers = [aws_iam_role.main.arn]
    } 
  }
}

# IAM - Create k8s Role
resource "aws_iam_role" "deploy_role" {
  name = "k8srole"
  assume_role_policy = data.aws_iam_policy_document.deploy_role.json
  force_detach_policies = true
}