resource "aws_security_group" "timescaledb" {
  name        = "${var.environment}-${var.name}-sg"
  description = "TimescaleDB EC2"
  vpc_id      = var.vpc_id

  tags = var.tags
}