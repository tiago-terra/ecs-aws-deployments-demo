provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "tf-remote-state-bucket-tiago"
    key            = "global/s3/terraform.tfstate"
    dynamodb_table = "terraform-up-and-running-locks"
    region         = "eu-west-2"
    encrypt        = true
  }
}