locals {
  env_vars = {
    ECR_REPO         = aws_ecr_repository.this.repository_url
    EKS_CLUSTER_NAME = data.aws_eks_cluster.cluster.name
  }
}

resource "aws_codebuild_project" "this" {
  name          = "${local.project_name}_codebuild"
  build_timeout = "5"
  service_role  = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = module.artifact_bucket.s3_bucket_id
  }

  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.env_vars

      content {
        name  = each.key
        value = each.value
      }
    }

    source {
      type      = "CODEPIPELINE"
      buildspec = "buildspec.yml"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${local.project_name}-codebuild-log"
      stream_name = "${local.project_name}-codebuild-log-stream"
    }
  }
}
