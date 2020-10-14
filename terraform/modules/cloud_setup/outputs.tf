output "codebuild_role" {
  value = aws_iam_role.main
}
output "codecommit_repo" {
  value = aws_codecommit_repository.main
}
output "ecr_repo" {
  value = aws_ecr_repository.main
}
output "iam_user_arn" {
  value = aws_iam_user.main.arn
}