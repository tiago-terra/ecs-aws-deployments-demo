terraform {
  backend "s3" {
    bucket  = "terraform-ecs-deployments-demo-state"
    key     = "infrastructure.tfstate"
    encrypt = true
    region  = "us-east-2"
  }
}
