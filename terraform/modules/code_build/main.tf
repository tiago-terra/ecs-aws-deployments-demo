locals {
  stages = ["build","deploy"]
}


resource "aws_codebuild_project" "main" {
  count         = length(local.stages)
  name          = "${element(local.stages,count.index)}_project"
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
    privileged_mode             = true
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
    buildspec = "${element(local.stages,count.index)}spec.yml"
  }
}