resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for onlog prod all-in-one EC2"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.name}-sg"
    }
  )
}

############################################################
# Ingress Rules
############################################################

# SSH (key-only)
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# HTTP (redirect to HTTPS)
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# HTTPS
resource "aws_security_group_rule" "https" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

############################################################
# Egress Rules
############################################################

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
