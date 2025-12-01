variable "name" {}
variable "vpc_id" {}
variable "node_sg_ids" {
  description = "List of NodeGroup SG IDs to allow outbound traffic"
  type        = list(string)
}
variable "tags" {
  type    = map(string)
  default = {}
}
