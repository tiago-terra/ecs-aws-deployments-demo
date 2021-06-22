# Pipeline configuration

Deploys CodePipeline, CodeBuild and associated services, targetting existing infrastructure

## Providers

| Name      | Version |
| --------- | ------- |
| aws       | n/a     |
| terraform | n/a     |

## Inputs

No input.

## Resources

data.aws_availability_zones.available
data.aws_caller_identity.current
data.terraform_remote_state.infrastructure
aws_codebuild_project.this
aws_codepipeline.blue_green
aws_codepipeline.rolling
aws_s3_bucket.this

## Outputs

No output.
