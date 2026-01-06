variable "name" {}
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "enable" {
  type    = bool
  default = true
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "control_plane_sg_id" {
  type = string
}

variable "eice_ssh_policy_arn" {
  description = "IAM policy ARN for EICE SSH receive"
  type        = string
}
