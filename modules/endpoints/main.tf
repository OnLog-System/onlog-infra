###############################################
# 1. Gateway Endpoints
###############################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-dynamodb-endpoint"
    }
  )
}

###############################################
# 2. Interface Endpoints
###############################################

locals {
  interface_services = {
    # ssm          = "com.amazonaws.${var.region}.ssm"
    # ssmmessages  = "com.amazonaws.${var.region}.ssmmessages"
    # ec2messages  = "com.amazonaws.${var.region}.ec2messages"
    ecr_api      = "com.amazonaws.${var.region}.ecr.api"
    ecr_docker   = "com.amazonaws.${var.region}.ecr.dkr"
    sts          = "com.amazonaws.${var.region}.sts"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_services

  vpc_id            = var.vpc_id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.endpoint_subnet_ids
  security_group_ids = [var.endpoint_sg_id]

  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${each.key}-endpoint"
    }
  )
}

###############################################
# 3. EC2 Instance Connect Endpoint (EICE)
###############################################

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id             = var.endpoint_subnet_ids[0]
  security_group_ids    = [var.eice_sg_id]
  preserve_client_ip    = false

  tags = merge(var.tags, {
    Name = "${var.environment}-eice-endpoint"
  })
}