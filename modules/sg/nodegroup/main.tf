resource "aws_security_group" "node" {
  name        = "${var.environment}-${var.name}-sg"
  description = "EKS NodeGroup SG"
  vpc_id      = var.vpc_id

  tags = var.tags
}
