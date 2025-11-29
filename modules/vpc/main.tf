############################
# 1. VPC 생성
############################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "onlog-vpc"
  }
}

############################
# 2. Subnet 생성
############################

# Public Subnets
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.availability_zones[idx]
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.value.az}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.availability_zones[idx % length(var.availability_zones)]
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "private-${each.value.az}-${each.key}"
  }
}

############################
# 3. IGW 생성
############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "onlog-igw"
  }
}

############################
# 4. NAT Gateway (옵션)
############################

# NAT를 둘 Public Subnet 선택
locals {
  nat_subnet_id = (
    var.enable_nat ?
    aws_subnet.public[
      element(
        [for k, v in aws_subnet.public : k if v.availability_zone == var.single_nat_az],
        0
      )
    ].id : null
  )
}

resource "aws_eip" "nat_eip" {
  count = var.enable_nat ? 1 : 0

  tags = {
    Name = "onlog-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = local.nat_subnet_id

  tags = {
    Name = "onlog-nat"
  }
}

############################
# 5. Route Tables
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "onlog-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat[0].id
    }
  }

  tags = {
    Name = "onlog-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
