variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "m6g.large"
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
  default = 50
}

variable "tags" {
  type = map(string)
}
