resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security Group for ALB"
  vpc_id      = var.vpc_id

  # Inbound: Internet to ALB
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
