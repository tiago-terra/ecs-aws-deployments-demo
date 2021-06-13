variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_user" {}

variable "project_name" {
  description = "Project Name"
  default = "eks_test"
}

variable "policies" {
	description = "IAM policies to be applied to user/role"
	default = [
		"arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
		# "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess",
		"arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
		"arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
		"arn:aws:iam::aws:policy/AmazonS3FullAccess",
		"arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
		"arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
		"arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
		"arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
	]
}