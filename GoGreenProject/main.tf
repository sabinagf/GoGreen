# configure aws providers
provider "aws" {
    region  = var.region
    profile = "terraform_user"
    }

#create vpc
module "GoGreenVpc" {
    source = "../modules/vpc"
    region                        = var.region
    project_name                  = var.project_name
    vpc_cidr                      = var.vpc_cidr
    public_subnet_az1_cidr        = var.public_subnet_az1_cidr
    public_subnet_az2_cidr        = var.public_subnet_az2_cidr
    private_app_subnet_az1_cidr   = var.private_app_subnet_az1_cidr
    private_app_subnet_az2_cidr   = var.private_app_subnet_az2_cidr
    private_data_subnet_az1_cidr  = var.private_data_subnet_az1_cidr
    private_data_subnet_az2_cidr  = var.private_data_subnet_az2_cidr
}