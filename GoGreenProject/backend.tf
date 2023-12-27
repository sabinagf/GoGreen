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

#CREATE AMAZON S3 GLACIER
resource "aws_glacier_vault" "s3_glacier" {
  name = "s3_glacier"
}