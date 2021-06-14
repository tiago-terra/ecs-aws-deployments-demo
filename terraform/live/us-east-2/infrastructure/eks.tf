module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.20"
  cluster_name    = local.eks_cluster_name
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  tags            = local.tags
  map_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = data.aws_caller_identity.current.account_id
      groups   = ["system:masters"]
    }
  ]
  worker_groups = [
    {
      name                 = "worker-group"
      instance_type        = "t3.micro"
      asg_desired_capacity = 2
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
