terraform {
  backend "s3" {
    bucket         = "onlog-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "onlog-terraform-lock"
    encrypt        = true
  }
}