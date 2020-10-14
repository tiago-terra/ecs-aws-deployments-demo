resource "aws_codepipeline" "main" {
  name     = "pipeline_${var.project_name}"
  role_arn = var.role_arn

  artifact_store {
    location = var.artifacts_bucket
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
        ProjectName = "build_project"
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