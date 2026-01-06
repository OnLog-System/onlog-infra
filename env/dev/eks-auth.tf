data "aws_eks_cluster_auth" "this" {
  name = module.eks_control_plane.cluster_name
}

provider "kubernetes" {
  host                   = module.eks_control_plane.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_control_plane.cluster_ca)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      # 1. EKS NodeGroup Role (Core / Batch 공통)
      {
        rolearn  = module.eks_control_plane.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },

      # 2. Terraform 관리자 (GitHub Actions / Local)
      {
        rolearn  = var.admin_role_arn
        username = "terraform-admin"
        groups = [
          "system:masters"
        ]
      }
    ])
  }
}
