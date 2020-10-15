variable "tf_bucket" {
  description = "S3 bucket"
}
variable "services" {
  description = "IAM policy services to associate with role"
  default = [
    "cloudwatch.amazonaws.com",
    "codebuild.amazonaws.com",
    "codecommit.amazonaws.com",
    "codepipeline.amazonaws.com",
    "eks.amazonaws.com",
    "s3.amazonaws.com"
    ]
}
variable "service_user_name" {
  description = "IAM user name"
}
variable "service_role_name" {
  description = "IAM role name"
}
variable "region" {
  description = "AWS Region"
}