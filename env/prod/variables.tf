############################################################
# prod 전용 최소 변수
############################################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "ssh_allowed_cidrs" {
  description = "SSH 접근 허용 CIDR"
  type        = list(string)
  default     = [
    "49.142.2.10/32" # 집/학교 IP
  ]
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "onlog-prod-key"
}
