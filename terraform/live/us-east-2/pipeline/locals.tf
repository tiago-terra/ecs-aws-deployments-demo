locals {
  project_name = "ecs-deployments-demo"
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

  tags = {
    Project     = local.project_name
    Description = "ECS Demo Project to demonstrate different deployment strategies within AWS"
    Terraform   = true
  }
}
