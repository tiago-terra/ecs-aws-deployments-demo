provider "aws" {
  region = "us-east-2"
}

locals {
  project_name = "terraform-ecs-deployments-demo"
  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}

module "state_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.project_name}-state"
  acl    = "private"
  tags   = local.tags

  versioning = {
    enabled = true
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
  tags = local.tags
}
