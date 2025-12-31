resource "aws_security_group" "msk" {
  name        = "${var.environment}-${var.name}-sg"
  description = "MSK Broker SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kafka IAM TLS"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}-sg" }
  )
}
