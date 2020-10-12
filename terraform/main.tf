module "code_commit" {
  source          = "./modules/code_commit"
  repository_name = "deployment_project"
}

module "code_build" {
  source = "./modules/code_build"
}

module "code_pipeline" {
  source = "./modules/code_pipeline"
}

