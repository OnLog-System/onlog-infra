resource "aws_eks_cluster" "this" {
  count = var.enable ? 1 : 0
  
  name     = "${var.environment}-${var.name}"
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster[0].arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.control_plane_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_controller,
  ]

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}" }
  )

}
