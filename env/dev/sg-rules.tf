############################################################
# SG Relations (Rules Only)
# - All inter-SG traffic is managed here
# - aws_security_group resources define GROUP only
############################################################


############################################################
# 1. ALB ↔ NodeGroup (Service / NodePort)
############################################################

# ALB → Node (Service traffic via NodePort)
resource "aws_security_group_rule" "alb_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_alb.id
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  description              = "ALB to NodeGroup NodePort traffic"
}

# Node → ALB (response traffic)
resource "aws_security_group_rule" "node_to_alb" {
  type                     = "egress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_alb.id
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  description              = "NodeGroup response traffic to ALB"
}


############################################################
# 2. Control Plane ↔ NodeGroup (Kubernetes Control)
############################################################

# ControlPlane → Node (kubelet / health checks)
resource "aws_security_group_rule" "controlplane_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_controlplane.id
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  description              = "EKS Control Plane to kubelet on NodeGroup"
}

# Node → ControlPlane
resource "aws_security_group_rule" "node_to_controlplane" {
  type                     = "egress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_controlplane.id
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  description              = "NodeGroup communication to EKS Control Plane"
}


############################################################
# 3. VPC Interface Endpoints ↔ NodeGroup (AWS APIs)
############################################################

# Node → Endpoints (AWS API calls: ECR, SSM, Logs, etc.)
resource "aws_security_group_rule" "node_to_endpoints" {
  type                     = "egress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_endpoints.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "NodeGroup outbound HTTPS to VPC Interface Endpoints"
}

# Endpoints → Node (response traffic)
resource "aws_security_group_rule" "endpoints_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_endpoints.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "VPC Interface Endpoints response traffic to NodeGroup"
}


############################################################
# 4. EC2 Instance Connect Endpoint (EICE) → NodeGroup (SSH)
############################################################

# EICE → Node (SSH access)
resource "aws_security_group_rule" "eice_to_node" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_eice.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH access from EC2 Instance Connect Endpoint to NodeGroup"
}


############################################################
# 5. NodeGroup Internal Communication (Self-Reference)
############################################################

