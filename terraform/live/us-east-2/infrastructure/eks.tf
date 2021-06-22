module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name           = local.eks_cluster_name
  cluster_version        = "1.20"
  subnets                = module.vpc.public_subnets
  vpc_id                 = module.vpc.vpc_id
  kubeconfig_output_path = "./.terraform/"
  tags                   = local.tags

  map_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = data.aws_caller_identity.current.account_id
      groups   = ["system:masters"]
    }
  ]
  map_roles = [
    {
      rolearn  = aws_iam_role.this.arn
      username = aws_iam_role.this.name
      groups   = ["system:masters"]
    }
  ]
  node_groups = {
    workers = {
      name                      = "${local.project_name}_worker"
      desired_capacity          = 2
      max_capacity              = 4
      min_capacity              = 1
      source_security_group_ids = [aws_security_group.this.id]
      instance_type             = "t3.micro"
    }
  }
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
