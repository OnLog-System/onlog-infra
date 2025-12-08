variable "environment" { type = string }
variable "region" { type = string }

variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }

variable "tags" {
  type = map(string)
}
