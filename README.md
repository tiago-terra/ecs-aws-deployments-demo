# AWS Deployment Strategies Use Case

Technical use case project aimed at demonstrating different deployment strategies within AWS.

## Tools used

- [AWS CodeCommit](https://aws.amazon.com/codecommit/)
- [AWS CodeBuild](https://aws.amazon.com/codebuild/)
- [AWS CodePipeline](https://aws.amazon.com/codepipeline/)
- [AWS ECR](https://aws.amazon.com/ecr/)
- [AWS EKS](https://aws.amazon.com/eks/)
- Docker
- Terraform

## Deployments

- Blue/Green Deployment
- Rolling Deployment

## Terraform

### Remote State

- **S3 bucket** - to store the state
- **DynamoDB** - to manage locks

#### Initialize remote state:

`cd remote_state && terraform apply -auto-approve`
