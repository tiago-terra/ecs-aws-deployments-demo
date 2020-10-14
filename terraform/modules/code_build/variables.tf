variable "stage" {
    default = ["build","deploy"]
}
variable "project_name" {}
variable "ecr_repo" {}
variable "role_arn" {}