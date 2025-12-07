variable "name" {}
variable "vpc_id" { type = string }
variable "environment" { type = string }
variable "tags" { type = map(string) }
variable "private_cidrs" { type = list(string) }
