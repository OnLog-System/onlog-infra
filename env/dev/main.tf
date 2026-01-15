############################################################
# 1. VPC Module
############################################################

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  nat_az             = var.nat_az

  # NAT Instance (optional)
  nat_network_interface_id = (
    var.enable_nat_instance
    ? module.nat_instance["enabled"].nat_network_interface_id
    : null
  )

  environment = var.environment
  tags        = var.tags
}

############################################################
# 2. SG: ALB
############################################################

module "sg_alb" {
  source      = "../../modules/sg/alb"
  name        = "alb"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 3. SG: Control Plane
############################################################

module "sg_controlplane" {
  source      = "../../modules/sg/controlplane"
  name        = "controlplane"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 4. SG: Endpoints (SSM, ECR, Logs 등)
############################################################

module "sg_endpoints" {
  source      = "../../modules/sg/endpoints"
  name        = "endpoints"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 5. SG: NodeGroup
############################################################

module "sg_node" {
  source      = "../../modules/sg/nodegroup"
  name        = "node"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 6. SG: EICE
############################################################

module "sg_eice" {
  source      = "../../modules/sg/eice"
  name        = "eice"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 7. VPC Endpoints + EICE
############################################################

module "endpoints" {
  source = "../../modules/endpoints"

  region      = var.region
  environment = var.environment
  vpc_id      = module.vpc.vpc_id

  # Interface Endpoints Subnets: automatically select one representative private subnet per AZ
  endpoint_subnet_ids = values(module.vpc.app_private_subnets_by_az)

  endpoint_sg_id = module.sg_endpoints.id
  eice_sg_id     = module.sg_eice.id

  # Gateway Endpoint Route Tables
  private_route_table_ids = [
    module.vpc.private_route_table_id
  ]

  tags = var.tags
}


############################################################
# 8. SG: NAT
############################################################

module "sg_nat" {
  source   = "../../modules/sg/nat"
  for_each = var.enable_nat_instance ? { enabled = true } : {}

  name          = "nat"
  vpc_id        = module.vpc.vpc_id
  environment   = var.environment
  private_cidrs = var.private_subnet_cidrs
  tags          = var.tags
}


############################################################
# 9. NAT Instance Module (ASG 기반)
############################################################

module "nat_instance" {
  source   = "../../modules/nat-instance"
  for_each = var.enable_nat_instance ? { enabled = true } : {}

  environment       = var.environment
  region            = var.region
  instance_type     = var.nat_instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.sg_nat["enabled"].id
  nat_az            = var.nat_az
  tags              = var.tags
}

############################################################
# 10. SG: MSK
############################################################
module "sg_msk" {
  source      = "../../modules/sg/msk"
  name        = "msk"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

############################################################
# 11. MSK Cluster
############################################################
module "msk" {
  count                    = var.enable_msk ? 1 : 0
  source                   = "../../modules/msk"
  name                     = "msk"
  environment              = var.environment
  kafka_version            = "3.8.x"
  availability_zones       = var.availability_zones
  brokers_per_az           = 1
  subnet_ids               = values(module.vpc.data_private_subnets_by_az)
  security_group_ids       = [module.sg_msk.id]
  broker_instance_type     = "kafka.t3.small"
  ebs_volume_size          = 10
  enable_msk_public_access = var.enable_msk_public_access
  tags                     = var.tags
}

############################################################
# 12. EKS Control Plane
############################################################

module "eks_control_plane" {
  source              = "../../modules/eks"
  name                = "eks"
  environment         = var.environment
  enable              = var.enable_eks
  cluster_version     = "1.34"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  eice_ssh_policy_arn = aws_iam_policy.eice_ssh_receive.arn
  tags                = var.tags
}

############################################################
# 13. EKS Node Groups (core / batch)
############################################################

module "eks_nodegroups" {
  for_each         = var.enable_eks ? var.nodegroups : {}
  source           = "../../modules/eks-nodegroup"
  name             = each.key
  environment      = var.environment
  enable           = true
  cluster_name     = module.eks_control_plane.cluster_name
  node_role_arn    = module.eks_control_plane.node_role_arn
  subnet_ids       = values(module.vpc.app_private_subnets_by_az)
  node_sg_ids      = [module.sg_node.id]
  instance_type    = each.value.instance_type
  root_volume_size = each.value.root_volume_size
  desired_size     = each.value.desired_size
  min_size         = each.value.min_size
  max_size         = each.value.max_size
  capacity_type    = each.value.capacity_type
  labels           = each.value.labels
  key_name         = "dev-admin-bastion-labpc"
  tags             = var.tags
}

############################################################
# 14. SG: Admin Bastion 
############################################################

module "sg_admin_bastion" {
  source      = "../../modules/sg/admin-bastion"
  name        = "admin-bastion"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

############################################################
# 15. Admin Bastion Instance
############################################################

module "admin_bastion" {
  source              = "../../modules/admin-bastion"
  name                = "admin-bastion"
  environment         = var.environment
  instance_type       = "t4g.nano"
  subnet_id           = values(module.vpc.app_private_subnets_by_az)[0]
  security_group_id   = module.sg_admin_bastion.id
  key_name            = aws_key_pair.admin_bastion_labpc.key_name
  tailscale_auth_key  = var.tailscale_auth_key
  eice_ssh_policy_arn = aws_iam_policy.eice_ssh_receive.arn
  tags                = var.tags
}

############################################################
# 16. EKS Addons
############################################################
module "eks_addons" {
  source = "../../modules/eks-addons"

  cluster_name  = module.eks_control_plane.cluster_name
  enable_addons = var.enable_eks
  depends_on    = [module.eks_control_plane, module.eks_nodegroups]
}

############################################################
# 17. SG: TimescaleDB
############################################################
module "sg_timescaledb" {
  source      = "../../modules/sg/timescaledb"
  name        = "timescaledb"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}


############################################################
# 18. TimescaleDB EC2 Instance
############################################################
module "timescaledb" {
  source             = "../../modules/timescaledb"
  count              = var.enable_timescaledb ? 1 : 0
  name               = "timescaledb"
  subnet_id          = values(module.vpc.data_private_subnets_by_az)[0]
  security_group_ids = [module.sg_timescaledb.id]
  instance_type      = "m6g.large"
  data_volume_size   = 200
  wal_volume_size    = 100
  key_name           = aws_key_pair.admin_bastion_labpc.key_name
  environment        = var.environment
  tags               = var.tags
}

#############################################################
# 19. SG: Kafka Streams
#############################################################
module "sg_kafka_streams" {
  source      = "../../modules/sg/kafka-streams"
  name        = "kafka-streams"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

#############################################################
# 20. Kafka Streams
#############################################################
module "kafka_streams" {
  source             = "../../modules/kafka-streams"
  name               = "kafka-streams"
  environment        = var.environment
  subnet_id          = values(module.vpc.app_private_subnets_by_az)[0]
  security_group_ids = [module.sg_kafka_streams.id]
  key_name           = aws_key_pair.admin_bastion_labpc.key_name
  tags               = var.tags
}