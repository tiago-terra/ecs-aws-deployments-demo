module "cloud_setup" {
  source = "./modules/cloud_setup"

  public_key = var.public_key
  project_name = var.project_name
}

module "code_build" {
  source = "./modules/code_build"

  project_name = "codebuild-${var.project_name}"
  service_role = module.cloud_setup.codebuild_role
  ecr_repo = module.cloud_setup.ecr_repo
}

module "code_pipeline" {
  source = "./modules/code_pipeline"

  project_name = var.project_name
  service_role = module.cloud_setup.codebuild_role
  cloudcommit_repo = module.cloud_setup.codecommit_repo
} 