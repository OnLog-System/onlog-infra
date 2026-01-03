output "cluster_name" {
  value = var.enable ? aws_eks_cluster.this[0].name : null
}

output "cluster_endpoint" {
  value = var.enable ? aws_eks_cluster.this[0].endpoint : null
}

output "cluster_arn" {
  value = var.enable ? aws_eks_cluster.this[0].arn : null
}

output "oidc_provider_arn" {
  value = var.enable ? aws_iam_openid_connect_provider.eks[0].arn : null
}

output "node_role_arn" {
  value = var.enable ? aws_iam_role.eks_node[0].arn : null
}
