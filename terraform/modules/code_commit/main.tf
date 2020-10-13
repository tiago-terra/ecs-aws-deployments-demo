#Create CodeCommit Repository
resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = var.repo_name
  description     = "Repository ${var.repo_name}"
  default_branch  = "master"
}

resource "null_resource" "codecommit_push" {
  provisioner "local-exec" {
    command = "git push ssh://${var.ssh_key_id}@${trimprefix(aws_codecommit_repository.deployment_repo.clone_url_ssh,"ssh://")} --all"

  }
}