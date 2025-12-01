variable "name" {}
variable "environment" {
  type = string
}
variable "vpc_id" {}

variable "admin_cidrs" {
  description = "Allowed CIDRs for kubectl access"
  type        = list(string)
}

variable "node_sg_ids" {
  description = "NodeGroup SGs"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
