terraform {
  backend "s3" {
    bucket  = "terraform-ecs-deployments-demo"
    key     = "infrastructure.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
