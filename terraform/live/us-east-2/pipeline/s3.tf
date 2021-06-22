resource "aws_s3_bucket" "this" {
  bucket        = "${local.project_name}-artifacts"
  acl           = "private"
  force_destroy = true
  tags          = local.tags

  versioning {
    enabled = true
  }
}
