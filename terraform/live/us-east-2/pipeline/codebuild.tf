locals {
  codebuild_env_vars = {
    ECR_REPO         = data.terraform_remote_state.infrastructure.outputs.ecr_repo_url
    EKS_CLUSTER_NAME = data.terraform_remote_state.infrastructure.outputs.eks_cluster_name
    PROJECT_NAME     = local.project_name
    REPLICA_COUNT    = 2
  }
}

resource "aws_codebuild_project" "this" {
  name          = local.project_name
  service_role  = local.role_arn
  build_timeout = "5"

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.this.bucket
  }

  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.codebuild_env_vars

      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${local.project_name}-codebuild-log"
      stream_name = "${local.project_name}-codebuild-log-stream"
    }
  }
}
