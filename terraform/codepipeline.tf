# Build S3 bucket for CodePipeline artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts"
  acl    = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_codepipeline" "rolling" {
  name     = "${var.project_name}-rolling"
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
        PollForSourceChanges = false
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
      output_artifacts = ["BuildOutput"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
        EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"rolling\"}]"
      }
    }
  }
}

resource "aws_codepipeline" "bluegreen" {
  name     = "${var.project_name}-bluegreen"
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
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "DeployBlue"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
        EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"blue\"}]"
      }
    }
  }

  stage {
    name = "ManualApproval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    
      configuration = {
        CustomData = "Check cluster is up"
        ExternalEntityLink = "aws eks update-kubeconfig --name ${data.aws_eks_cluster.cluster.name}"
      }
    }
  }

  stage {
    name = "DeployGreen"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
        EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"green\"}]"
      }
    }
  }
}