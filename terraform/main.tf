module "cloud_setup" {
  source = "./modules/cloud_setup"

  public_key = var.public_key
  project_name = var.project_name
  user_name = data.aws_iam_user.main.user_name
}

module "cloudbuild_build" {
  source = "./modules/code_build"

  stage = "build"
  role_arn = data.aws_iam_role.main.arn
  ecr_repo = module.cloud_setup.ecr_repo
}


module "cloudbuild_deploy" {
  source = "./modules/code_build"

  project_name = "codebuild-${var.project_name}"
  role_arn = data.aws_iam_role.main.arn
  ecr_repo = module.cloud_setup.ecr_repo
}

module "code_pipeline" {
  source = "./modules/code_pipeline"
  
  artifacts_bucket = module.cloud_setup.artifacts_bucket
  code_repo = module.cloud_setup.code_repo
  project_name = var.project_name
  role_arn = data.aws_iam_role.main.arn
}