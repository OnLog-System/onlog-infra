variable "name" {}
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "enable" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "control_plane_sg_id" {
  type = string
}
