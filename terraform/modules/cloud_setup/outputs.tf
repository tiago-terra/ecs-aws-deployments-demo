output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}
output "code_repo" {
  value = aws_codecommit_repository.main
}
output "ecr_repo" {
  value = aws_ecr_repository.main
}