############################################################
# 1. VPC Module
############################################################

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat    = var.enable_nat
  single_nat_az = var.single_nat_az

  environment = var.environment

  tags = var.tags
}

############################################################
# 2. SG: NodeGroup (기본 SG 먼저 생성)
############################################################

module "sg_node_base" {
  source = "../../modules/sg/nodegroup"

  name = "node"
  vpc_id = module.vpc.vpc_id
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

  name = "alb"
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

  name = "controlplane"
  vpc_id = module.vpc.vpc_id
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

  name = "endpoints"
  vpc_id = module.vpc.vpc_id
  environment = var.environment

  node_sg_ids = [module.sg_node_base.id]

  tags = var.tags
}

############################################################
# 6. SG: NodeGroup Final (다른 SG를 연결한 최종 구조)
############################################################

module "sg_node" {
  source = "../../modules/sg/nodegroup"

  name = "node"
  vpc_id = module.vpc.vpc_id
  environment = var.environment

  alb_sg_ids          = [module.sg_alb.id]
  controlplane_sg_ids = [module.sg_controlplane.id]
  endpoint_sg_ids     = [module.sg_endpoints.id]

  tags = var.tags
}
