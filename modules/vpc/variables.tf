variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of AZs to assign to subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = true
}

variable "nat_az" {
  description = "AZ where the NAT Gateway will be placed"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  type = string
}

variable "nat_instance_id" {
  type    = string
  default = null
}

variable "nat_network_interface_id" {
  type    = string
  default = null
}
