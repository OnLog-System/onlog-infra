############################################################
# EKS Access Entry - Admin
############################################################

resource "aws_eks_access_entry" "admin" {
  count         = var.enable_eks ? 1 : 0
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = "arn:aws:iam::858923558183:user/terraform-dev-user"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  count         = var.enable_eks ? 1 : 0
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = aws_eks_access_entry.admin[0].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "yoonseok" {
  count         = var.enable_eks ? 1 : 0
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = "arn:aws:iam::858923558183:user/yoonseok.kang"
}

resource "aws_eks_access_policy_association" "yoonseok_admin" {
  count         = var.enable_eks ? 1 : 0
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = aws_eks_access_entry.yoonseok[0].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
