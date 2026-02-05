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
# 1. VPC (Single AZ / Single Public Subnet)
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

  ssh_allowed_cidrs = var.ssh_allowed_cidrs

  tags = local.tags
}

############################################################
# 3. EC2 (All-in-One)
# - FastAPI
# - TimescaleDB
# - Grafana
# - Batch / Replay
############################################################
module "onlog_prod_ec2" {
  source = "../../modules/timescaledb"

  name               = "onlog-prod"
  environment        = "prod"

  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.sg_onlog_prod.id]

  instance_type = "t4g.large"
  key_name      = var.key_name

  # Storage
  data_volume_size = 100
  wal_volume_size  = 50

  tags = merge(
    local.tags,
    {
      Role = "all-in-one"
    }
  )
}
