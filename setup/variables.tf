variable "policies" {
    default = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
        "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
        "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
        "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess",
        "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        ]
}

variable "services" {
    default = [
      "eks.amazonaws.com",
      "cloudwatch.amazonaws.com",
      "codecommit.amazonaws.com",
      "codebuild.amazonaws.com",
      "codepipeline.amazonaws.com",
      "s3.amazonaws.com"
      ]
}