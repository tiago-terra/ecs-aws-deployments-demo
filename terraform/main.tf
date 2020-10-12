module "setup" {
  source          = "./modules/setup"
  repo_name = var.repo_name
}

# module "code_build" {
#   source = "./modules/code_build"
#   project_name = "codebuild-${var.repo_name}"
#   role_arn = module.setup.iam_role_arn

# }
