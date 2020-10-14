resource "random_uuid" "deploy" {}

# Build S3 bucket for CodePipeline artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "artifacts-${random_uuid.deploy.result}"
  acl    = "private"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_codepipeline" "main" {
  name     = "pipeline_${var.project_name}"
  role_arn = var.service_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.project_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "codebuild-${var.project_name}"
      }
    }
  }

  # stage {
  #   name = "Deploy"

  #   action {
  #     name            = "Deploy Image to K8S"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "CodeBuild"
  #     input_artifacts = ["SourceArtifact"]
  #     version         = "1"

  #     configuration = {
  #       ProjectName = var.project_name
  #     }
  #   }
  # }

}