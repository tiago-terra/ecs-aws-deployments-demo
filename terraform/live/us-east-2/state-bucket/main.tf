provider "aws" {
  region = "us-east-2"
}

locals {
  project_name = "terraform-ecs-deployments-demo"
}

module "state_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.project_name}-state"
  acl    = "private"

  versioning = {
    enabled = true
  }
  lifecycle {
    prevent_destroy = false
  }
}

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = "${local.project_name}-state-lock"
  hash_key = "lockID"
  attributes = [
    {
      name = "lockID"
      type = "S"
    }
  ]
}
