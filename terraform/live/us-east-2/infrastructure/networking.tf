module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "${local.project_name}-vpc"
  azs             = data.aws_availability_zones.names
  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}

resource "aws_security_group" "management" {
  name_prefix = "management"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [22, 80]

    content {
      from_port   = each.value
      to_port     = each.value
      protocol    = "tcp"
      cidr_blocks = module.vpc.public_subnets
    }
  }
}
