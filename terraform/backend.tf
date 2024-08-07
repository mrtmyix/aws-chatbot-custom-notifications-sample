
terraform {
  backend "s3" {
    bucket  = "" # S3 bucket name
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform"
  }
}