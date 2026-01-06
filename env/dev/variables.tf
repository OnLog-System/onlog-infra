############################################################
# 환경 기본 정보
############################################################

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type = map(string)
}

############################################################
# VPC 설정
############################################################

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

############################################################
# EKS ControlPlane 관련
############################################################

variable "admin_cidrs" {
  description = "kubectl 접근 허용 CIDR 목록"
  type        = list(string)
}

############################################################
# VPC Endpoint 설정
############################################################

variable "endpoint_subnet_group" {
  description = "endpoint 를 private subnet 에 만들지 public 에 만들지"
  type        = string
}

############################################################
# NAT 관련 설정
############################################################

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_nat_instance" {
  type    = bool
  default = false
}

variable "nat_instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "nat_az" {
  type = string
}

############################################################
# EKS 관련 설정
############################################################

variable "nodegroups" {
  type = map(object({
    instance_type    = string
    root_volume_size = number
    desired_size     = number
    min_size         = number
    max_size         = number
    capacity_type    = optional(string, "ON_DEMAND")
    labels           = optional(map(string), {})
  }))
}

############################################################
# Admin Bastion Key Pair
############################################################

variable "admin_bastion_public_key_yoonseok_labpc" {
  type = string
}

variable "admin_bastion_public_key_yoonseok_notepc" {
  type = string
}

############################################################
# Tailscale
############################################################

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

############################################################
# EKS - aws-auth
############################################################

variable "admin_role_arn" {
  description = "Terraform / kubectl admin IAM Role ARN"
  type        = string
}









#############################################################
# Enable 관리
#############################################################

variable "enable_msk" {
  type    = bool
  default = true
}

variable "enable_msk_public_access" {
  type    = bool
  default = false
}

variable "enable_eks" {
  type    = bool
  default = true
}


