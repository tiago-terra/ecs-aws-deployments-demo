module "cloud_setup" {
  source = "./modules/cloud_setup"
  public_key = var.public_key
}

module "code_commit" {
  source = "./modules/code_commit"
  repo_name = var.project_name
  ssh_key_id = module.cloud_setup.ssh_key_id
}

# module "code_build" {
#   source = "./modules/code_build"
#   project_name = "codebuild-${var.project_name}"
#   service_role = module.cloud_setup.codebuild_role_arn
# }



