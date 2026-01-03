resource "aws_security_group" "controlplane" {
  name        = "${var.environment}-${var.name}-sg"
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

  tags = var.tags
}
