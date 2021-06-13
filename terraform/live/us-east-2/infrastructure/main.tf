provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  project_name     = "ecs-deployments-demo"
  region           = "us-east-2"
  eks_cluster_name = "${local.project_name}_cluster"
  policies_to_attach = formatlist("arn:aws:iam::aws:policy/%s",
    [
      "AmazonEC2ContainerRegistryPowerUser",
      "AmazonEC2ContainerServiceFullAccess",
      "AmazonEKSClusterPolicy",
      "AmazonEKSServicePolicy",
      "AmazonS3FullAccess",
      "AWSCodeBuildAdminAccess",
      "AWSCodeCommitFullAccess",
      "AWSCodePipeline_FullAccess",
      "CloudWatchLogsFullAccess"
  ])
}

# ECR Repository
resource "aws_ecr_repository" "main" {
  name = local.project_name
}

# Attach IAM Policies
resource "aws_iam_user_policy_attachment" "main" {
  for_each   = local.existing_policies
  user       = data.aws_caller_identity.account_id
  policy_arn = each.value
}


