resource "aws_security_group" "msk" {
  name        = "${var.environment}-${var.name}-sg"
  description = "MSK Broker SG"
  vpc_id      = var.vpc_id

  tags = var.tags
}
