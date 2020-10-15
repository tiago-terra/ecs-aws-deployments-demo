provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

module "cloud_setup" {
  source = "./cloud_setup"

  public_key = var.public_key
  project_name = var.project_name
  role_name = var.role_name
  user_name = var.user_name
  region = var.region
}