# AWS Deployment Strategies Use Case

Technical use case project aimed at demonstrating different deployment strategies within AWS:

- Blue/Green Deployments
- Rolling Deployments

# Tools 
## Prerequisites
- An IAM user account
- The AWS credentials are setup in the user path

## Required locally
- terraform
- kubectl
- helm

## Tools used

| Tool                                                     |
| :------------------------------------------------------- |
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

## Inputs

| Variable     | Required | Description                                  |
| :----------- | :------- | :------------------------------------------- |
| region       | true     | AWS region                                   |
| user_name    | true     | Service user's name                          |
| role_name    | true     | Service role name                            |
| project_name | true     | Project name to be applied to resources      |
| policies     | false    | IAM policies to apply to service users/roles |

## Create infrastructure


# Kubernetes

For the purposes of testing the deployments, an EKS cluster is setup. Alongside, a node group is created.
Testing the cluster is possible from the CLI. To configure kubectl connection to cluster:
`aws eks update-kubeconfig --cluster-name $EKS_CLUSTER_NAME`

# TODO

Neither green/blue necessarily live
Canary deployments
build build image
