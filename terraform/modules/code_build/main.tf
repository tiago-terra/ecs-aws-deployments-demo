resource "aws_codebuild_project" "deployment_project" {
  name          = var.project_name
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = var.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.16"
    }
  }


  source {
    type      = "CODEPIPELINE"
    buildspec = "./buildspec.yml"
  }

  tags = {
    Terraform = "true"
  }
}

# Output TF Plan CodeBuild name to main.tf
output "codebuild_terraform_plan_name" {
  value = var.codebuild_name
}
