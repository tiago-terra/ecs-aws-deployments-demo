terraform {
  backend "s3" {
    bucket  = "terraform-ecs-deployments-demo"
    key     = "pipeline.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
