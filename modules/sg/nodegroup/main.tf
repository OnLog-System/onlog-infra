resource "aws_security_group" "node" {
  name        = "${var.environment}-${var.name}-sg"
  description = "EKS NodeGroup SG"
  vpc_id      = var.vpc_id

  # Allow ALB → NodeGroup
  ingress {
    description     = "ALB to NodeGroup"
    from_port       = var.app_port_min
    to_port         = var.app_port_max
    protocol        = "tcp"
    security_groups = var.alb_sg_ids
  }

  # Allow NodeGroup internal communication (Pod ↔ Pod, Node ↔ Node)
  ingress {
    description = "Node internal communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow Control Plane → NodeGroup
  ingress {
    description     = "ControlPlane to Node"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = var.controlplane_sg_ids
  }

  # Outbound: Node → AWS Endpoints
  egress {
    description     = "Node to Endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.endpoint_sg_ids
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
