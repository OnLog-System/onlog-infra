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
variable "root_volume_size" {}

variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}

variable "capacity_type" {}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type = map(string)
}
