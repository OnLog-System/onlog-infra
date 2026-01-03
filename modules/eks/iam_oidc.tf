resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable ? 1 : 0

  url = data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint
  ]

  tags = var.tags

  depends_on = [
    aws_eks_cluster.this
  ]
}

data "aws_eks_cluster" "this" {
  count = var.enable ? 1 : 0
  name  = aws_eks_cluster.this[0].name
}

data "tls_certificate" "oidc" {
  count = var.enable ? 1 : 0
  url   = data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}
