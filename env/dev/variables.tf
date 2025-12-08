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

