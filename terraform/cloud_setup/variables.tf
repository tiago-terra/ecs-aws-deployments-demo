variable "public_key" {
    description = "Public SSH key to be associated with the IAM user"
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
variable "region" {
    description = "AWS region"
}
variable "policies" {
    description = "IAM policies to be applied to user/role"
    default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ]
}