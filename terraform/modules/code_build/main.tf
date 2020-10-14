resource "null_resource" "push_to_codecommit" {

  provisioner "local-exec" {
    command = "whoami && git push aws"
  }
}

resource "aws_codebuild_project" "main" {
  name          = var.project_name
  build_timeout = "5"
  service_role  = var.service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "nginx"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  
    environment_variable {
      name = "ECR_REPO"
      value = var.ecr_repo.repository_url
    }
 
    environment_variable {
      name = "IMAGE_TAG"
      value = "web_container:latest"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/buildspec.yml"
  }
}