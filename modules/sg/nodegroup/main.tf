resource "aws_security_group" "node" {
  name        = "${var.environment}-${var.name}-sg"
  description = "EKS NodeGroup SG"
  vpc_id      = var.vpc_id

  # Allow NodeGroup internal communication (Pod ↔ Pod, Node ↔ Node)
  ingress {
    description = "Node internal communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Outbound: internal node communication
  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  tags = var.tags
}
