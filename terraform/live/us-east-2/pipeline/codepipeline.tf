locals {
  blue_env_vars = {
    name  = "DEPLOY_TYPE"
    value = "blue"
  }
  green_env_vars = {
    name  = "DEPLOY_TYPE"
    value = "green"
  }
}

resource "aws_codepipeline" "this" {
  name     = "${local.project_name}-pipeline"
  role_arn = data.aws_iam_role.this.arn

  artifact_store {
    location = module.artifact_bucket.s3_bucket_id
    type     = "S3"
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
    name = "DeployToBlue"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.this.name
        EnvironmentVariables = local.blue_env_vars
      }
    }
  }

  stage {
    name = "ManualConfirmDeployToGreen"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData         = "Confirm new version features are functional on BLUE ENVIRONMENT"
        ExternalEntityLink = ""
      }
    }
  }
  stage {
    name = "DeployToGreen"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.this.name
        EnvironmentVariables = local.green_env_vars
      }
    }
  }

  stage {
    name = "RunGreenTests"
  }
  stage {
    name = "ManualRollback"
  }
}


/* 
resource "aws_codepipeline" "iam_build" {
  name     = "${local.project_name}-iam-pipeline"
  role_arn = "NA"

  artifact_store {
    location = ""
    type     = "S3"
  }

}


 */


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
