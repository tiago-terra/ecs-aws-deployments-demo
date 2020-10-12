module "setup" {
  source          = "./modules/setup"
  repo_name = var.repo_name

}

module "code_build" {
  source = "./modules/code_build"
  build_timeout = "5"
  project_name = "codebuild-${var.repo_name}"
  role_arn = ""
  
}

module "code_pipeline" {
  source = "./modules/code_pipeline"
}

