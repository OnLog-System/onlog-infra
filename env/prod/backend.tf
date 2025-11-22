terraform {
  backend "s3" {
    bucket         = "onlog-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "onlog-terraform-lock"
    encrypt        = true
  }
}