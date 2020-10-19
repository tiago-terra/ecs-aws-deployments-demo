# AWS Deployment Strategies Use Case

Technical use case project aimed at demonstrating different deployment strategies within AWS:

- Blue/Green Deployments
- Rolling Deployments

#Tools

## Required locally

- terraform
- kubectl

## Tools used

| Tool                                                     |
| -------------------------------------------------------- |
| [AWS CodeCommit](https://aws.amazon.com/codecommit/)     |
| [AWS CodeBuild](https://aws.amazon.com/codebuild/)       |
| [AWS CodePipeline](https://aws.amazon.com/codepipeline/) |
| [AWS ECR](https://aws.amazon.com/ecr/)                   |
| [AWS EKS](https://aws.amazon.com/eks/)                   |
| Docker                                                   |
| Terraform                                                |
| S3 bucket - to store the state                           |
| DynamoDB - to manage locks                               |

# Terraform

## Initializing Terraform remote state

`cd terraform/cloud_init && terraform apply -auto-approve`

## Initializing terraform with backend config

- Create tfvars file from sample
  `cd terraform && mv config_sample config.tfvars`
- edit the newly created config.tfvars file
- Initialize terraform:
  `terraform init --backend-config=config.tfvars`

## Create infrastructure

`cd terraform && terraform apply -auto-approve`

# Kubernetes

For the purposes of testing the deployments, an EKS cluster is setup. Alongside, a node group is created.
Testing the cluster is possible from the CLI
