# CodeCommit - Create repo
resource "aws_codecommit_repository" "main" {
  repository_name = var.project_name
  description     = "Repository ${var.project_name}"
  default_branch  = "master"
}

# ECR - Create repo
resource "aws_ecr_repository" "main" {
  name                 = "nginx_ds"
  image_tag_mutability = "MUTABLE"
}

# EKS - Create cluster
resource "aws_eks_cluster" "main" {
  name     = "eks_${var.project_name}"
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]
  role_arn = aws_iam_role.deploy_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.blue.id, aws_subnet.green.id]
  }

  # Update kubeconfig
  provisioner "local-exec" {
    command = "export AWS_DEFAULT_PROFILE=default && aws eks --region ${var.region} update-kubeconfig --name ${self.name}"
  }
  # Replace aws-auth vars
  provisioner "local-exec" {
    command = "export DEPLOY_ROLE_ARN=${aws_iam_role.deploy_role.arn} && envsubst '$DEPLOY_ROLE_ARN' < ../k8s/aws-auth.yml > aws-auth_tmp.yml"
  }
  # Apply configMap
  provisioner "local-exec" {
    command = "kubectl apply -f aws-auth_tmp.yml && rm aws-auth_tmp.yml"
  }
}