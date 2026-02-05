variable "name" {}
variable "environment" {
  type = string
}
variable "vpc_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}