module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["ap-northeast-2a"]

  public_subnet_cidrs = [
    "10.1.1.0/24"
  ]

  private_subnet_cidrs = [
    "10.1.11.0/24",
    "10.1.21.0/24"
  ]

  enable_nat    = true
  single_nat_az = "ap-northeast-2a"
}
