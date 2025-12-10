resource "aws_security_group" "eice" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security Group for EC2 Instance Connect Endpoint"
  vpc_id      = var.vpc_id

  # EICE → EC2 SSH 전달 (Outbound)
  egress {
    description = "EICE to EC2 SSH outbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 기타 outbound 허용 (필요한 AWS API 등)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
