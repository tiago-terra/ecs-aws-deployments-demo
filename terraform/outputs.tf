output "ecr_repo" {
  value = module.cloud_setup.ecr_repo
}
output "eks_cluster_endpoint" {
  value = module.cloud_setup.eks_cluster_endpoint
}
output "eks_cluster_ca_data" {
  value = module.cloud_setup.eks_cluster_ca_data
}