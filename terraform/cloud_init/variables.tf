variable "tf_bucket" {
  default = "tf-remote-state-bucket-tiago"
}
variable "tf_lock_table" {
  default = "terraform-up-and-running-locks"
}
variable "services" {
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
  default = "service_user"
}

variable "service_role_name" {
  default = "service_role"
}
variable "region" {
  default = "eu-west-2"
}