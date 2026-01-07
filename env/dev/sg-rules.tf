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

# ControlPlane → Node (kubelet)
resource "aws_security_group_rule" "cluster_sg_to_node_kubelet" {
  count                    = var.enable_eks ? 1 : 0
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.eks_control_plane.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  description              = "EKS Control Plane to NodeGroup kubelet"
}

# ControlPlane → Node (API)
resource "aws_security_group_rule" "cluster_sg_to_node_api" {
  count                    = var.enable_eks ? 1 : 0
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.eks_control_plane.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "EKS Control Plane to NodeGroup API"
}

# Node → ControlPlane
resource "aws_security_group_rule" "node_to_cluster_sg" {
  count                    = var.enable_eks ? 1 : 0
  type                     = "egress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.eks_control_plane.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "NodeGroup to EKS Control Plane"
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

# Node ↔ Node (Pod-to-Pod, Node-to-Node)
resource "aws_security_group_rule" "node_self" {
  type              = "ingress"
  security_group_id = module.sg_node.id
  self              = true
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  description       = "Internal NodeGroup communication (ingress)"
}

# Node → Node (egress)
resource "aws_security_group_rule" "node_self_egress" {
  type              = "egress"
  security_group_id = module.sg_node.id
  self              = true
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  description       = "Internal NodeGroup communication (egress)"
}


############################################################
# 6. MSK (Kafka) Access
############################################################

# Node → MSK (IAM TLS)
resource "aws_security_group_rule" "node_to_msk" {
  type                     = "ingress"
  security_group_id        = module.sg_msk.id
  source_security_group_id = module.sg_node.id
  from_port                = 9098
  to_port                  = 9098
  protocol                 = "tcp"
  description              = "EKS NodeGroup to MSK (IAM TLS)"
}

############################################################
# 7. NodeGroup → Internet (NAT via Private Subnet)
############################################################

resource "aws_security_group_rule" "node_to_internet" {
  type              = "egress"
  security_group_id = module.sg_node.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "NodeGroup outbound internet access via NAT"
}


############################################################
# 8. VPC Interface Endpoints ↔ NodeGroup (HTTPS)
############################################################

resource "aws_security_group_rule" "endpoints_to_node_https" {
  type                     = "ingress"
  security_group_id        = module.sg_node.id
  source_security_group_id = module.sg_endpoints.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "VPC Interface Endpoints to EKS NodeGroup (HTTPS)"
}

resource "aws_security_group_rule" "endpoints_egress_all" {
  type              = "egress"
  security_group_id = module.sg_endpoints.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "VPC Interface Endpoints outbound response traffic"
}
