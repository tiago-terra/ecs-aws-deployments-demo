provider "aws" {
  profile = "default"
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-remote-store"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.project_name}-app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
