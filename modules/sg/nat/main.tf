resource "aws_security_group" "nat" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for NAT Instance"
  vpc_id      = var.vpc_id

  # Allow all incoming traffic from private subnets
  ingress {
    description = "Private Subnet → NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_cidrs
  }

  # NAT → Internet
  egress {
    description = "NAT to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
