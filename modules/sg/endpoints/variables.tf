variable "name" {}
variable "vpc_id" {}
variable "node_sg_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
