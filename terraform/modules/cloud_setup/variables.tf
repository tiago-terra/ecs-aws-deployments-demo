variable "public_key" {}
variable "policy_arns" {
    default = [
        "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
        "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"    
        ]
}
variable "project_name" {}