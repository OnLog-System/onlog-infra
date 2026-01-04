variable "name" {}
variable "environment" {}

variable "enable" {
  type    = bool
  default = true
}

variable "cluster_name" {}
variable "node_role_arn" {}

variable "subnet_ids" {
  type = list(string)
}

variable "node_sg_ids" {
  type = list(string)
}

variable "instance_type" {
  default = "t4g.small"
}

variable "root_volume_size" {
  default = 20
}

variable "desired_size" {
  default = 2
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 3
}

variable "capacity_type" {
  default = "ON_DEMAND"
}

variable "tags" {
  type = map(string)
}
