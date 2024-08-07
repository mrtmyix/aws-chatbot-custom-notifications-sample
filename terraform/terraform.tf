
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~>1.8"
    }
  }
  required_version = "~> 1.9"
}