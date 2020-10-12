resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = "deployment_repo"
  description     = "Repo to host deployment strategies use case project"
  default_branch = "master"
}

output "repo_id" {
    value = aws_codecommit_repository.deployment_repo.repository_id
}

output "clone_url_http" {
    value = aws_codecommit_repository.deployment_repo.clone_url_http
}