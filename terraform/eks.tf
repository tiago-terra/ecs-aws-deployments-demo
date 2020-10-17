locals {
  roles_to_map = [
    {
        rolearn  = data.aws_iam_role.main.arn
        username = data.aws_iam_role.main.name
        groups   = ["system:masters"]
    }
  ]
  users_to_map = [
    {
        userarn  = data.aws_iam_user.main.arn
        username = data.aws_iam_user.main.user_name
        groups   = ["system:masters"]
    }
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-cluster"
  cluster_version = "1.15"
  cluster_iam_role_name = aws_iam_role.deploy_role.name
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  manage_cluster_iam_resources = false
  map_roles       = local.roles_to_map
  map_users       = local.users_to_map
  worker_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}