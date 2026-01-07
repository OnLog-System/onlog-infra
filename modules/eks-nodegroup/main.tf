resource "aws_eks_node_group" "this" {
  count = var.enable ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = "${var.environment}-${var.name}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  ami_type = "AL2023_ARM_64_STANDARD"
  instance_types = [var.instance_type]
  capacity_type  = var.capacity_type

  remote_access {
    ec2_ssh_key  = "dev-admin-bastion-labpc"
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.labels
  tags = var.tags
}
