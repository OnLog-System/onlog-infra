############################################################
# VPC & Subnet
############################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

############################################################
# Security Groups
############################################################

output "sg_node" {
  description = "NodeGroup Security Group ID"
  value       = module.sg_node.id
}

output "sg_alb" {
  description = "ALB Security Group ID"
  value       = module.sg_alb.id
}

output "sg_controlplane" {
  description = "Control Plane Security Group ID"
  value       = module.sg_controlplane.id
}

output "sg_endpoints" {
  description = "VPC Endpoint Security Group ID"
  value       = module.sg_endpoints.id
}

############################################################
# MSK
############################################################
output "msk_bootstrap_brokers_iam" {
  description = "MSK IAM bootstrap brokers"
  value       = module.msk.bootstrap_brokers_iam
}