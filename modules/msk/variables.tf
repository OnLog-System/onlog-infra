variable "name" {}
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "kafka_version" { type = string }

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "broker_instance_type" {
  type = string
}

variable "ebs_volume_size" {
  type = number
}

variable "availability_zones" {
  type        = list(string)
  description = "MSK가 배치될 AZ 목록"
}

variable "brokers_per_az" {
  type        = number
  description = "AZ당 Kafka 브로커 수"
  default     = 1
}

variable "enable_msk_public_access" {
  type    = bool
}