############################################################
# Common Tags
############################################################
locals {
  tags = {
    Project     = "onlog"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

############################################################
# 1. VPC (Single AZ / Public only)
############################################################
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.20.0.0/16"
  availability_zones = ["ap-northeast-2a"]

  public_subnet_cidrs  = ["10.20.1.0/24"]
  private_subnet_cidrs = []

  enable_nat_gateway = false
  environment        = "prod"
  tags               = local.tags
}

############################################################
# 2. Security Group (onlog prod)
############################################################
module "sg_onlog_prod" {
  source = "../../modules/sg/onlog-prod"

  name        = "onlog-prod"
  vpc_id      = module.vpc.vpc_id
  environment = "prod"

  # SSH: key-only (IP 제한 없음)
  ssh_allowed_cidrs = ["0.0.0.0/0"]

  tags = local.tags
}

############################################################
# 3. EC2 (All-in-One)
############################################################
module "onlog_prod_ec2" {
  source = "../../modules/ec2-onlog-prod"

  name               = "onlog-prod"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.sg_onlog_prod.id]
  key_name           = aws_key_pair.onlog_prod_labpc.key_name

  instance_type = "t4g.large"
  data_volume_size = 100

  tags = local.tags
}
