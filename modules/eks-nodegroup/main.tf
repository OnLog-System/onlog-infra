resource "aws_eks_node_group" "this" {
  count = var.enable ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = "${var.environment}-${var.name}"
  node_role_arn  = var.node_role_arn
  subnet_ids     = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  launch_template {
    id      = aws_launch_template.this[0].id
    version = aws_launch_template.this[0].latest_version
  }

  capacity_type = var.capacity_type
  ami_type      = "AL2_ARM_64"

  labels = var.labels
  dynamic "taints" {
    for_each = var.taints
    content {
      key    = taints.value.key
      value  = taints.value.value
      effect = taints.value.effect
    }
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags
}
