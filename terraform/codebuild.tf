resource "aws_codebuild_project" "main" {
  name          = var.project_name
  build_timeout = "5"
  service_role  = data.aws_iam_role.main.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  cache {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }
  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  
    environment_variable {
      name = "ECR_REPO"
      value = aws_ecr_repository.main.repository_url
    }
    environment_variable {
      name = "EKS_CLUSTER_NAME"
      value = data.aws_eks_cluster.cluster.name
    }    
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}