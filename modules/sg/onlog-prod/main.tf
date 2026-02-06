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

# ----------------------------------------------------------
# SSH (관리용)
# TODO: 추후 RPi 고정 IP / Bastion / Tailscale로 제한
# ----------------------------------------------------------
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ----------------------------------------------------------
# HTTP (현재 사용 중)
# - Edge → Nginx → FastAPI
# - 추후 HTTPS로 redirect 예정
# ----------------------------------------------------------
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ----------------------------------------------------------
# HTTPS (아직 미사용, 곧 사용 예정)
# - 도메인 + Let's Encrypt 이후 활성
# ----------------------------------------------------------
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
