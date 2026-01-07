resource "aws_eks_node_group" "this" {
  count = var.enable ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = "${var.environment}-${var.name}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this[0].id
    version = "$Latest"
  }

  capacity_type = var.capacity_type

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.labels
  tags = var.tags
}
