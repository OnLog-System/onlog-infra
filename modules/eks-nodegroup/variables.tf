variable "enable" {}
variable "name" {}
variable "environment" {}

variable "cluster_name" {}
variable "node_role_arn" {}

variable "subnet_ids" {
  type = list(string)
}

variable "node_sg_ids" {
  type = list(string)
}

variable "instance_type" {}

variable "ami_id" {
  type = string
  description = "EKS Optimized AL2023 ARM64 AMI ID"
}
variable "root_volume_size" {}

variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}

variable "capacity_type" {}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
}

variable "tags" {
  type = map(string)
}
