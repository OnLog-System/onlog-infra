resource "aws_security_group" "controlplane" {
  name        = "${var.environment}-${var.name}-sg"
  description = "EKS Control Plane SG"
  vpc_id      = var.vpc_id

  tags = var.tags
}
