############################################################
# prod 전용 최소 변수
############################################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}