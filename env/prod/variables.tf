############################################################
# prod 전용 최소 변수
############################################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "onlog-prod-key"
}
