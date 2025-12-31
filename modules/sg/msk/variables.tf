variable "name" {}
variable "environment" { type = string }
variable "vpc_id" { type = string }

variable "allowed_cidrs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
