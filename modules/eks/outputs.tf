output "cluster_name" {
  value = var.enable ? aws_eks_cluster.this[0].name : null
}

output "cluster_endpoint" {
  value = var.enable ? aws_eks_cluster.this[0].endpoint : null
}

output "cluster_arn" {
  value = var.enable ? aws_eks_cluster.this[0].arn : null
}
