provider "aws" {
    region  = var.region
    profile ="default"
}

# Remote Backend
terraform {
  backend "s3" {
    bucket         = "tf-remote-state-bucket-tiago"
    key            = "global/s3/terraform.tfstate"
    dynamodb_table = "terraform-up-and-running-locks"
    region         = "eu-west-2"
    encrypt        = true
  }
}


module "cloud_setup" {
  source = "./cloud_setup"

  public_key = var.public_key
  project_name = var.project_name
  role_name = var.role_name
  user_name = var.user_name
  region = var.region
}
