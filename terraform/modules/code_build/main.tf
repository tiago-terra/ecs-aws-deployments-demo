resource "aws_codebuild_project" "main" {
  name          = var.project_name
  build_timeout = "5"
  service_role  = var.role_arn

  artifacts {
    type = "CODEPIPELINE"
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
    image_pull_credentials_type = "CODEBUILD"
  
    environment_variable {
      name = "ECR_REPO"
      value = var.ecr_repo.repository_url
    }
 
    environment_variable {
      name = "IMAGE_TAG"
      value = "web_container:latest"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}