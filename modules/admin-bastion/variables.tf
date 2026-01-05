variable "name" {}
variable "environment" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}

variable "tags" {
  type = map(string)
}

variable "key_name" {
  type        = string
  description = "SSH key pair name for admin bastion"
}