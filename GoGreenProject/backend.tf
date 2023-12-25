# backend.tf
# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket  = "gogreen.bucket"
    encrypt = true
    key     = "gogreenproject"
    region  = "us-east-2" # Replace with your desired AWS region
    profile = "terraform-user"
  }
}

