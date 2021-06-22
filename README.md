# AWS Deployment Strategies Use Case

Technical use case project aimed at demonstrating different deployment strategies within EKS in AWS:

- Blue/Green Deployments - by triggering a CodePipeline pipeline which will deploy blue and green versions of an application to an EKS cluster, with a manual confirmation step.
- Rolling Deployments - by triggering a CodePipeline pipeline which will update an existing application running on an EKS cluster in a rolling manner.

## Prerequisites

- IAM access to create roles and access the different AWS services
- A CodeCommit repo created

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

# Instructions

**1. Initializing Terraform remote state**

`terraform apply --auto-approve --chdir ./terraform/live/us-east-2/remote-state`

**2. Deploy the infrastructure (including EKS cluster)**

`terraform apply --auto-approve --chdir ./terraform/live/us-east-2/infrastructure`

**3. Deploy Codebuild and Codepipeline resources**

`terraform apply --auto-approve --chdir ./terraform/live/us-east-2/pipeline`

# Kubernetes

For the purposes of testing the deployments, an EKS cluster is setup. Alongside, a node group is created.
Testing the cluster is possible from the CLI. To configure kubectl connection to cluster:

1. `aws login --region $AWS_REGION`
2. `aws eks update-kubeconfig --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION`

# TODO

- Canary deployments
- build build image
