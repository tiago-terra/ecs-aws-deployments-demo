#CodeCommit - Create Repo
resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = var.repo_name
  description     = "Repository ${var.repo_name}"
  default_branch  = "master"
}

# IAM Policies - Create data objects
data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codecommit_policy" {
  statement {
    actions = [
      "codecommit:BatchGet*",
      "codecommit:BatchDescribe*",
      "codecommit:Describe*",
      "codecommit:EvaluatePullRequestApprovalRules",
      "codecommit:Get*",
      "codecommit:List*",
      "codecommit:GitPull"
    ]
    resources = [aws_codecommit_repository.deployment_repo.arn]
  }
  statement {
    actions = ["iam:Get*", "iam:List*","sts:AssumeRole"]
    resources = [aws_iam_role.codebuild_role.arn]
  }
}

# IAM Policies - Create role policies
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild_service_role"
  assume_role_policy =  data.aws_iam_policy_document.role_policy.json
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${aws_iam_role.codebuild_role.name}_policy"
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codecommit_policy.json
}