#configure aws providers
provider "aws" {
  region = var.region
}
# terraform {
#   cloud {
#     organization = "terraform_class990"

#     workspaces {
#       name = "terraform-aws-security-groups"
#     }
#   }
# }


# terraform {
#   cloud {
#     organization = "terraform_class990"

#     workspaces {
#       name = "Gogreen"
#     }
#   }
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# Configure the AWS Provider
# provider "aws" {
#   region = "us-east-2"
# }