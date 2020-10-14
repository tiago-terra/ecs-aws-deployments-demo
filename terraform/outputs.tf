output "codecommit_repo" {
    value = module.cloud_setup.codecommit_repo
}

output "codebuild_role" {
  value = module.cloud_setup.codebuild_role
}
output "ecr_repo" {
  value = module.cloud_setup.ecr_repo
}
output "iam_user_arn" {
  value = module.cloud_setup.iam_user_arn
}