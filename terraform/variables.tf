variable "region" {
    description = "AWS region"
}
variable "project_name" {
    description = "Project name, to be used in resource naming"
}
variable "user_name" {
    description = "IAM user name"
}
variable "role_name" {
    description = "IAM role name"
}
variable "public_key" {
    description = "Public SSH key to be associated with the IAM user"
}