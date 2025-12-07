resource "aws_security_group" "nat" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for NAT Instance"
  vpc_id      = var.vpc_id

  # Inbound (Private Subnet → NAT)
  ingress {
    description = "Private Subnet to NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_cidrs
  }

  # Outbound → Internet 가능
  egress {
    description = "NAT to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
