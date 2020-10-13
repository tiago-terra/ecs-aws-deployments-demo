resource "aws_codebuild_project" "main" {
  name          = var.project_name
  build_timeout = "5"
  service_role  = var.service_role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "nginx"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${var.build_path}/buildspec.yml"
  }
}