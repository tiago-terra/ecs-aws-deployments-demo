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
########################################################################
# IAM
########################################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = formatlist("%s.amazonaws.com", ["codebuild", "codecommit", "codepipeline", "eks", "s3"])
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.project_name}_cicd_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "pipeline_policy"
    policy = data.aws_iam_policy_document.this.json
  }
}
