output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.orders_api.repository_url
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "update_kubeconfig_command" {
  value = module.eks.update_kubeconfig_command
}
