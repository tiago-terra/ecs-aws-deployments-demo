locals {
  blue_vars    = jsonencode([{ name = "DEPLOY_TYPE", value = "blue" }])
  green_vars   = jsonencode([{ name = "DEPLOY_TYPE", value = "green" }])
  rolling_vars = jsonencode([{ name = "DEPLOY_TYPE", value = "rolling" }])
}

resource "aws_codepipeline" "blue_green" {
  name     = "${local.project_name}-bluegreen-pipeline"
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
  # Build and Deploy to Blue
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
        EnvironmentVariables = local.blue_vars
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
        CustomData = "Check cluster is up - aws eks update-kubeconfig --name ${local.eks_cluster_name} && kubectl get svc"
      }
    }
  }

  # Build and Deploy to Green
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
        EnvironmentVariables = local.green_vars
      }
    }
  }
}

resource "aws_codepipeline" "rolling" {
  name     = "${local.project_name}-rolling-pipeline"
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
        RepositoryName       = local.project_name
        BranchName           = "master"
        PollForSourceChanges = false
      }
    }
  }

  # Build and Deploy
  stage {
    name = "DeployRolling"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.this.name
        EnvironmentVariables = local.rolling_vars
      }
    }
  }
}
