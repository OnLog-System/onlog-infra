########################################
# EKS Addons Module
########################################
locals {
  enabled = var.enable_addons
}

#########################################
# VPC CNI Addon
#########################################
resource "aws_eks_addon" "vpc_cni" {
  count        = local.enabled ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_addon.kube_proxy
  ]
}

#########################################
# Kube-Proxy Addon
#########################################
resource "aws_eks_addon" "kube_proxy" {
  count        = local.enabled ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
}

#########################################
# CoreDNS Addon
#########################################
resource "aws_eks_addon" "coredns" {
  count        = local.enabled ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "coredns"

  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}
#########################################
# EBS CSI Driver Addon
#########################################

resource "aws_iam_role" "ebs_csi" {
  count = local.enabled ? 1 : 0
  name  = "${var.cluster_name}-ebs-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = local.enabled ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  count        = local.enabled ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi[0].arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi,
    aws_eks_addon.coredns
  ]
}



