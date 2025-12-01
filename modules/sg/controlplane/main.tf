resource "aws_security_group" "controlplane" {
  name        = "${var.name}-controlplane-sg"
  description = "EKS Control Plane SG"
  vpc_id      = var.vpc_id

  # kubectl → API Server
  ingress {
    description = "kubectl API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  # NodeGroup → ControlPlane (health check, kubelet)
  ingress {
    description     = "NodeGroup → ControlPlane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = var.node_sg_ids
  }

  # Outbound: ControlPlane → NodeGroup
  egress {
    description     = "ControlPlane → Node"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = var.node_sg_ids
  }

  tags = var.tags
}
