variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
}

variable "data_volume_size" {
  type    = number
}

variable "wal_volume_size" {
  type    = number
}

variable "key_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "enabled" {
  type    = bool
}