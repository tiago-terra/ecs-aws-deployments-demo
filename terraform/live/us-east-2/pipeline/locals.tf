locals {
  project_name         = "ecs-aws-deployments-demo"
  role_name            = "${local.project_name}_pipeline_role"
  region               = "us-east-2"
  eks_cluster_endpoint = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}
