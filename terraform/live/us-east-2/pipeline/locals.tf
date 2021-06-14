locals {
  project_name = "ecs-aws-deployments-demo"
  region       = "us-east-2"
  policies_to_attach = [
    # CodeBuild/Pipeline
    "AWSCodeBuildAdminAccess",
    "AWSCodeCommitFullAccess",
    "AWSCodePipeline_FullAccess",
    # ECR
    "AmazonEC2ContainerRegistryPowerUser",
    "AmazonEC2ContainerServiceFullAccess",
    # EKS
    "AmazonEKSClusterPolicy",
    "AmazonEKSServicePolicy",

    "AmazonS3FullAccess",
    "CloudWatchLogsFullAccess"
  ]

  codebuild_env_vars = {
    ECR_REPO         = data.terraform_remote_state.infrastructure.outputs.ecr_repo_url
    EKS_CLUSTER_NAME = data.terraform_remote_state.infrastructure.outputs.eks_cluster_name
  }

  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}
