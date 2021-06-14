locals {
  project_name     = "ecs-aws-deployments-demo"
  eks_cluster_name = "${local.project_name}_cluster"
  region           = "us-east-2"

  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}
