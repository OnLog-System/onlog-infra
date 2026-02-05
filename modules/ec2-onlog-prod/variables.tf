variable "name" {
  description = "EC2 name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (public)"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "data_volume_size" {
  description = "EBS data volume size (GB)"
  type        = number
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
