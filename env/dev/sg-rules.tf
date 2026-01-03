############################################################
# SG Relations (Rules Only)
############################################################

# ALB → Node (NodePort)
resource "aws_security_group_rule" "alb_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_alb.id
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
}

# ControlPlane → Node (kubelet)
resource "aws_security_group_rule" "controlplane_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_controlplane.id
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
}

# Node → Endpoints
resource "aws_security_group_rule" "node_to_endpoints" {
  type                     = "egress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_endpoints.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

# EICE → Node (SSH)
resource "aws_security_group_rule" "eice_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_eice.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}
