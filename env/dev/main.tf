############################################################
# 1. VPC Module
############################################################

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat    = var.enable_nat_gateway
  single_nat_az = var.single_nat_az
  nat_instance_id = module.nat_instance.nat_instance_id

  environment = var.environment
  tags = var.tags
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

  tags = var.tags
}

############################################################
# 7. VPC Endpoint Module
############################################################

module "endpoints" {
  source = "../../modules/endpoints"

  region      = var.region
  environment = var.environment
  vpc_id      = module.vpc.vpc_id

  # Interface Endpoints Subnets: automatically select one representative private subnet per AZ
  endpoint_subnet_ids = values(module.vpc.app_private_subnets_by_az)

  endpoint_sg_id = module.sg_endpoints.id

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
  source = "../../modules/sg/nat"
  for_each = var.enable_nat_instance ? { enabled = true } : {}

  name          = "nat"
  vpc_id        = module.vpc.vpc_id
  environment   = var.environment
  private_cidrs = var.private_subnet_cidrs
  tags          = var.tags
}


############################################################
# 9. NAT Instance Module
############################################################

module "nat_instance" {
  source = "../../modules/nat-instance"
  for_each = var.enable_nat_instance ? { enabled = true } : {} # true 일 때만 생성

  environment        = var.environment
  region             = var.region
  instance_type      = var.nat_instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]    # ap-northeast-2a
  security_group_id  = module.sg_nat["enabled"].id
  ami_id             = "ami-0b2c2a754d12345" # Amazon NAT AMI ID (서울 리전) #맞는지 확인!
  tags               = var.tags
}
