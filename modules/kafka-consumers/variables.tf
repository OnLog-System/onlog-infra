variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
}
