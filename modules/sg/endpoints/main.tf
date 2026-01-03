resource "aws_security_group" "endpoints" {
  name        = "${var.environment}-${var.name}-sg"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  tags = var.tags
}
