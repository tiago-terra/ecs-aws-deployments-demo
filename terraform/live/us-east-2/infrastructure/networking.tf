module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${local.project_name}-vpc"
  azs                  = data.aws_availability_zones.available.names
  cidr                 = local.vpc_cidr
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets
  enable_dns_hostnames = true
  single_nat_gateway   = true
  enable_nat_gateway   = true
  tags                 = local.tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}

resource "aws_security_group" "http_in" {
  name_prefix = "management"
  vpc_id      = module.vpc.vpc_id
  tags        = local.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.public_subnets
  }
}
