provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "tf-remote-state-bucket-tiago"

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
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# IAM Operations
resource "aws_iam_user" "main" {
  name = "service_user"
  path = "/"
}

resource "aws_iam_user_policy_attachment" "user_attachment" {
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