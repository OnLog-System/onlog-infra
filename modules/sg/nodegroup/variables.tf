variable "name" {}
variable "environment" {
  type = string
}
variable "vpc_id" {}

variable "alb_sg_ids" {
  type = list(string)
}

variable "controlplane_sg_ids" {
  type = list(string)
}

variable "endpoint_sg_ids" {
  type = list(string)
}

variable "app_port_min" { default = 30000 }
variable "app_port_max" { default = 32767 }

variable "tags" {
  type    = map(string)
  default = {}
}
