provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "terraform-up-and-running-locks"

  versioning {
    enabled = true
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
}