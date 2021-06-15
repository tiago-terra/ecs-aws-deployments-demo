locals {
  project_name         = "ecs-aws-deployments-demo"
  region               = "us-east-2"
  role_arn             = data.terraform_remote_state.infrastructure.outputs.role_arn
  eks_cluster_endpoint = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}
