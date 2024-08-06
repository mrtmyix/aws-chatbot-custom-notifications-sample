
terraform {
  backend "s3" {
    bucket  = "your-bucket-name" # Replace with your bucket name
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform"
  }
}