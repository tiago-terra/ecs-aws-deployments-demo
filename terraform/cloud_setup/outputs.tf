output "ecr_repo" {
  value = aws_ecr_repository.main.repository_url
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "eks_cluster_ca_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}