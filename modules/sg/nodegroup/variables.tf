variable "name" {}
variable "environment" {
  type = string
}
variable "vpc_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eice_sg_ids" {
  type        = list(string)
  description = "Security Groups allowed to SSH into the nodes (EICE)"
  default     = []
}
