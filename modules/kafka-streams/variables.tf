variable "name" {
  type = string
}

variable "environment" {
  type = string
}
variable "ami_id" {}
variable "instance_type" {
  default = "m6g.large"
}
variable "subnet_id" {}
variable "security_group_ids" {
  type = list(string)
}
variable "iam_instance_profile" {}
variable "key_name" {}
variable "root_volume_size" {
  default = 50
}
variable "tags" {
  type = map(string)
}