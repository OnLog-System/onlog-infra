resource "aws_security_group" "msk" {
  name        = "${var.environment}-${var.name}-sg"
  description = "MSK Broker SG"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
