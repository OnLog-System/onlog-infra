resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Admin bastion SG"
  vpc_id      = var.vpc_id

  # outbound 전체 허용 (tailscale + 내부 통신)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
