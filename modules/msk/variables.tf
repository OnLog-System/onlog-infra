variable "name" {}
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "kafka_version" { type = string }

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "broker_instance_type" {
  type = string
}

variable "ebs_volume_size" {
  type = number
}
