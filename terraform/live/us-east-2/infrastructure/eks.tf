module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_version = "1.18"
  cluster_name    = local.eks_cluster_name
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  map_users = [
    {
      userarn  = data.aws_caller_identity.arn
      username = data.aws_caller_identity.account_id
      groups   = ["system:masters"]
    }
  ]
  node_groups = {
    workers = {
      desired_capacity          = 2
      max_capacity              = 2
      min_capacity              = 1
      source_security_group_ids = [aws_security_group.management.id]
      instance_types            = ["t3.micro"]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}
