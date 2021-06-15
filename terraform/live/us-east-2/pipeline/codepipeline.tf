locals {
  blue_env_vars = [{
    name  = "DEPLOY_TYPE"
    value = "blue"
  }]
  green_env_vars = [{
    name  = "DEPLOY_TYPE"
    value = "green"
  }]
}

resource "aws_codepipeline" "this" {
  name     = "${local.project_name}-pipeline"
  role_arn = aws_iam_role.this.arn

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
        EnvironmentVariables = jsonencode(local.blue_env_vars)
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
        EnvironmentVariables = jsonencode(local.green_env_vars)
      }
    }
  }
}


# resource "aws_codepipeline" "bluegreen" {
#   name     = "${local.project_name}-bluegreen"
#   role_arn = data.aws_iam_role.main.arn

#   stage {
#     name = "ManualApproval"

#     action {
#       name     = "Approval"
#       category = "Approval"
#       owner    = "AWS"
#       provider = "Manual"
#       version  = "1"

#       configuration = {
#         CustomData = "Check cluster is up - aws eks update-kubeconfig --name ${data.aws_eks_cluster.cluster.name} && kubectl get svc"
#         ExternalEntityLink = ""
#       }
#     }
#   }

#   stage {
#     name = "DeployGreen"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = ["SourceArtifact"]
#       version          = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.main.name
#         EnvironmentVariables = "[{\"name\":\"DEPLOY_TYPE\",\"value\":\"green\"}]"
#       }
#     }
#   }
# }
