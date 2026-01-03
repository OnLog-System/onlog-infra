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
# 2. SG: NodeGroup (기본 SG 먼저 생성)
############################################################

module "sg_node_base" {
  source = "../../modules/sg/nodegroup"

  name        = "node-base"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  alb_sg_ids          = []
  controlplane_sg_ids = []
  endpoint_sg_ids     = []
  eice_sg_ids         = []

  tags = var.tags
}

############################################################
# 3. SG: ALB
############################################################

module "sg_alb" {
  source = "../../modules/sg/alb"

  name        = "alb"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  node_sg_ids = [module.sg_node_base.id]

  tags = var.tags
}

############################################################
# 4. SG: Control Plane
############################################################

module "sg_controlplane" {
  source = "../../modules/sg/controlplane"

  name        = "controlplane"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  admin_cidrs = var.admin_cidrs
  node_sg_ids = [module.sg_node_base.id]

  tags = var.tags
}

############################################################
# 5. SG: Endpoints (SSM, ECR, Logs 등)
############################################################

module "sg_endpoints" {
  source = "../../modules/sg/endpoints"

  name        = "endpoints"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  node_sg_ids = [module.sg_node_base.id]

  tags = var.tags
}

############################################################
# 6. SG: NodeGroup Final (다른 SG를 연결한 최종 구조)
############################################################

module "sg_node" {
  source = "../../modules/sg/nodegroup"

  name        = "node"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  alb_sg_ids          = [module.sg_alb.id]
  controlplane_sg_ids = [module.sg_controlplane.id]
  endpoint_sg_ids     = [module.sg_endpoints.id]
  eice_sg_ids         = [module.sg_eice.id]

  tags = var.tags
}

############################################################
# 7. SG: EICE
############################################################

module "sg_eice" {
  source      = "../../modules/sg/eice"
  name        = "eice"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = var.tags
}

############################################################
# 8. VPC Endpoints + EICE
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
# 9. SG: NAT
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
# 10. NAT Instance Module (ASG 기반)
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
# 11. SG: MSK
############################################################
module "sg_msk" {
  source      = "../../modules/sg/msk"
  name        = "msk"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id

  allowed_cidrs = ["0.0.0.0/0"] # 실험 단계

  tags = var.tags
}

############################################################
# 12. MSK Cluster
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
# 13. EKS Control Plane
############################################################

module "eks_control_plane" {
  source              = "../../modules/eks"
  name                = "eks"
  environment         = var.environment
  enable              = var.enable_eks
  cluster_version     = "1.34"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  control_plane_sg_id = module.sg_controlplane.id
  tags                = var.tags
}
