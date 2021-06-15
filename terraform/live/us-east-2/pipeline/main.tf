data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-2"
}

########################################################################
# S3 Bucket
########################################################################
resource "aws_s3_bucket" "this" {
  bucket        = "${local.project_name}-artifacts"
  acl           = "private"
  force_destroy = true
  tags          = local.tags

  versioning {
    enabled = true
  }
}
