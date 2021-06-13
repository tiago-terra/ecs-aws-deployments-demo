resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts"
  acl    = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

# Code Pipeline
resource "aws_codepipeline" "main" {
  name     = "${var.project_name}-pipeline"
  role_arn = data.aws_iam_role.main.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

# Sets source to CodeCommit repo
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
      output_artifacts = ["BuildOutput"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
        EnvironmentVariables = ""
      }
    }
  }

  stage {
    name = "DeployToBlue"

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
    name = "RunBlueTests"
  }
  stage {
    name = "ManualConfirmDeployToGreen" 

    action   {
      name = "Approval"
      category = "Approval"
      owner = "AWS"
      provider = "Manual"
      version = "1"

      configuration = {
        CustomData = "Confirm new version features are functional on BLUE ENVIRONMENT"
        ExternalEntityLink = ""
      }
    }
  }
  stage {
    name = "DeployToGreen"
  }
  stage {
    name = "RunGreenTests"
  }
  stage {
    name = "ManualRollback"
  }
}

resource "aws_codepipeline" "iam_build" {
  name = "${var.project_name}-iam-pipeline"
  role_arn = "NA"
  
  artifact_store {
    location = ""
    type = "S3"
  }

}



# resource "aws_codepipeline" "bluegreen" {
#   name     = "${var.project_name}-bluegreen"
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