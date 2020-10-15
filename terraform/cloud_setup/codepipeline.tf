# Build S3 bucket for CodePipeline artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "artifacts-${var.project_name}"
  acl    = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_codepipeline" "main" {
  name     = "build-${var.project_name}"
  role_arn = data.aws_iam_role.main.arn

  
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
        RepositoryName = aws_codecommit_repository.main.repository_name
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
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }
}


resource "aws_codepipeline" "k8s" {
  name     = "pipeline-${var.project_name}"
  role_arn = data.aws_iam_role.main.arn

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
        RepositoryName = aws_codecommit_repository.main.repository_name
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
        ProjectName = "build-project"
      }
    }
  }
}