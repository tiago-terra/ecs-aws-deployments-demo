resource "aws_codebuild_project" "main" {
  name          = "ecr-build"
  build_timeout = "5"
  service_role  = data.aws_iam_role.main.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER" 
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  
    environment_variable {
      name = "ECR_REPO"
      value = aws_ecr_repository.main.repository_url
    }
    environment_variable {
      name = "EKS_CLUSTER_NAME"
      value = aws_eks_cluster.main.name
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/build/code_setup/buildspec.yml"
  }
}


resource "aws_codebuild_project" "bluegreen" {
  name          = "eks-blue-green"
  build_timeout = "5"
  service_role  = data.aws_iam_role.main.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  
    environment_variable {
      name = "ECR_REPO"
      value = aws_ecr_repository.main.repository_url
    }
    environment_variable {
      name = "EKS_CLUSTER_NAME"
      value = aws_eks_cluster.main.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/build/code_setup/bluegreen.yml"
  }
}


resource "aws_codebuild_project" "rolling" {
  name          = "eks-rolling"
  build_timeout = "5"
  service_role  = data.aws_iam_role.main.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  environment {
    image                       = "aws/codebuild/standard:4.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  
    environment_variable {
      name = "ECR_REPO"
      value = aws_ecr_repository.main.repository_url
    }
    environment_variable {
      name = "EKS_CLUSTER_NAME"
      value = aws_eks_cluster.main.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/build/code_setup/rolling.yml"
  }
}