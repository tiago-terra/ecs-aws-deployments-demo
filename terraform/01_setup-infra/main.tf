provider "aws" {
  profile = "default"
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}

terraform {  
    backend "s3" {
        bucket  = "tiago-test-terraform-remote-store"
        encrypt = true
        key     = "terraform.tfstate"    
        region  = "us-east-2"
    }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

# IAM
data "aws_iam_policy_document" "main" {
  statement {
    actions = ["eks:*"]
    resources = ["*"]
  }
}

data "aws_iam_user" "main" {
  user_name = var.aws_user
}

resource "aws_iam_policy" "main" {
  name = "AmazonEKSAdminPolicy"
  path = "/"
  policy = data.aws_iam_policy_document.main.json
}

locals {
  deploy_policies = concat(var.policies, [aws_iam_policy.main.arn])
}

resource "aws_iam_user_policy_attachment" "main" {
  count = length(local.deploy_policies)
  user = data.aws_iam_user.main.user_name
  policy_arn = element(local.deploy_policies, count.index)
}

# ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"
}



# EKS
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks_cluster"
  cluster_version = "1.18"
  subnets         = [aws_subnet.main.id, aws_subnet.secondary.id]
  vpc_id          = aws_vpc.main.id
  map_users = [
    {
      userarn = data.aws_iam_user.main.arn
      username = data.aws_iam_user.main.user_name
      groups   = ["system:masters"]
    }
    ]
  node_groups = {
    workers = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1
      source_security_group_ids	= [aws_security_group.worker_group_mgmt.id]
      instance_types = ["t3.micro"]
    }
  }
}