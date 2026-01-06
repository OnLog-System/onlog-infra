############################################################
# EKS Access Entry - Admin
############################################################

resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = "arn:aws:iam::858923558183:user/terraform-dev-user"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = aws_eks_access_entry.admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "yoonseok" {
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = "arn:aws:iam::858923558183:user/yoonseok.kang"
}

resource "aws_eks_access_policy_association" "yoonseok_admin" {
  cluster_name  = module.eks_control_plane.cluster_name
  principal_arn = aws_eks_access_entry.yoonseok.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
