provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}


# Bucket for artifacts
module "artifact_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project_name}-artifacts"
  acl    = "private"
  tags   = local.tags

  versioning = {
    enabled = true
  }
}

# IAM 
resource "aws_iam_role" "this" {
  name = "${local.project_name}_cicd_role"
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each   = toset(formatlist("arn:aws:iam::aws:policy/%s", local.policies_to_attach))
  user       = data.aws_caller_identity.current.account_id
  policy_arn = each.value
}
