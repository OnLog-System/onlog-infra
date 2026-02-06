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
# TODO: 추후 RPi 고정 IP 또는 Bastion / Tailscale로 제한
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
# HTTP (Nginx → HTTPS redirect)
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
# HTTPS (공식 외부 진입점)
# - Edge → API
# - Grafana 외부 접근
# ----------------------------------------------------------
resource "aws_security_group_rule" "https" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ----------------------------------------------------------
# FastAPI (8000)
# ⚠️ 임시: Edge 직접 연결 테스트용
# TODO: Nginx 도입 후 제거 예정
# ----------------------------------------------------------
resource "aws_security_group_rule" "fastapi_temp" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 8000
  to_port     = 8000
  protocol    = "tcp"

  # 테스트 단계에서는 임시로 전체 허용
  # cidr_blocks = ["<RPi_PUBLIC_IP>/32"]
  cidr_blocks = ["0.0.0.0/0"]
}

# ----------------------------------------------------------
# Grafana (3000)
# ⚠️ 선택 사항
# - HTTPS reverse proxy 붙이면 닫아도 됨
# ----------------------------------------------------------
resource "aws_security_group_rule" "grafana_optional" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"

  # 외부 공개 시
  cidr_blocks = ["0.0.0.0/0"]
}

# ----------------------------------------------------------
# PostgreSQL (5432)
# ⚠️ 원칙적으로 외부 미노출
# - 필요 시 Bastion / SSH tunnel / Tailscale
# ----------------------------------------------------------
# resource "aws_security_group_rule" "postgres_internal" {
#   type              = "ingress"
#   security_group_id = aws_security_group.this.id
#
#   from_port   = 5432
#   to_port     = 5432
#   protocol    = "tcp"
#
#   cidr_blocks = ["10.20.0.0/16"]
# }

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
