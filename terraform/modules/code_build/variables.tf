variable "project_name" {}
variable "ecr_repo" {}
variable "service_role" {}
variable "build_path" {
    default = "./modules/code_build/build"
}