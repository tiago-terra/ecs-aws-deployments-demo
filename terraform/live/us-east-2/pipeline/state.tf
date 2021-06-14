terraform {
  backend "s3" {
    bucket  = "terraform-ecs-deployments-demo-state"
    key     = "pipeline.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket  = "terraform-ecs-deployments-demo-state"
    key     = "infrastructure.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
