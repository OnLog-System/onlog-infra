variable "name" {}
variable "environment" {
  type = string
}
variable "vpc_id" {}
variable "node_sg_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
