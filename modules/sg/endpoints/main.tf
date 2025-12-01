resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints-sg"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  # NodeGroup → Endpoint
  ingress {
    description     = "NodeGroup → Endpoint 443"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.node_sg_ids
  }

  tags = var.tags
}
