variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

###############################################
# For Gateway Endpoints
###############################################

variable "private_route_table_ids" {
  description = "Private Route Table IDs for Gateway Endpoints"
  type        = list(string)
}

###############################################
# For Interface Endpoints
###############################################

variable "endpoint_subnet_ids" {
  description = "Subnets to place Interface Endpoints"
  type        = list(string)
}

variable "endpoint_sg_id" {
  description = "SG to attach to Interface Endpoints"
  type        = string
}

###############################################
# For EC2 Instance Connect Endpoint
###############################################

variable "eice_sg_id" {
  description = "SG ID for EC2 Instance Connect Endpoint"
  type = string
}

