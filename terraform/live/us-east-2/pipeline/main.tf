data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-2"
}

# Bucket for artifacts
module "artifact_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.project_name}-artifacts"
  acl    = "private"
  tags   = local.tags

  versioning = {
    enabled = true
  }
}
