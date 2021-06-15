resource "aws_codepipeline" "this" {
  name     = "${local.project_name}-pipeline"
  role_arn = local.role_arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.this.bucket
  }

  # Get Code from VCS
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
        RepositoryName = local.project_name
        BranchName     = "master"
      }
    }
  }

  #  Build artifact
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildOutput"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  stage {
    name = "DeployBlue"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.this.name
        EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"blue\"}]"
      }
    }
  }

  stage {
    name = "ManualApprovalToDeployToGreen"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData         = "Confirm new version features are functional on BLUE ENVIRONMENT"
        ExternalEntityLink = local.eks_cluster_endpoint
      }
    }
  }
  stage {
    name = "DeployGreen"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.this.name
        EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"green\"}]"
      }
    }
  }
}
