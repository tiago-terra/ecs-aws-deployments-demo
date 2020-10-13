output "codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
}

output "ecr_repo_url" {
  value = aws_ecr_repository.main
}

output "iam_user_arn" {
  value = aws_iam_user.main.arn
}

output "ssh_key_id" {
  value = aws_iam_user_ssh_key.main.ssh_public_key_id
}