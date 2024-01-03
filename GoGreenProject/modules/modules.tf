
# #CREATE SECURITY GROUPS
# resource "aws_security_group" "sg_az1" {
#   name        = "secgr-az1"
#   description = "Example security group for availability zone 1"

#   # Add ingress/egress rules specific to AZ1

#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_security_group" "sg_az2" {
#   name        = "secgr-az2"
#   description = "Example security group for availability zone 2"
#   # Add ingress/egress rules specific to AZ2


#   vpc_id = aws_vpc.vpc.id
# }

# module "aws_security_group"  {
#   source = "app.terraform.io/terraform_class990/security-groups/aws"
#       version = "3.0.0"
#       vpc_id = aws_vpc.vpc_id
      
#       security_groups = {
#         "bastion_sg" : {
#           description = "Application Load Balancer SG"
#           ingress_rules = [
#         {
#           from_port =22
#           to_port = 22
#           protocol = "tcp"
#           cidr_blocks = var.vpc_cidr
#         }
#           ]
#       egress_rules = [
#         {
#          from_port =0
#           to_port = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#       }
#       ]
#       }
#       }
# }

module "security_group" {
  source = "./modules/security-groups"
  vpc_id = aws_vpc.vpc.id
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
  project_name = var.project.name 
  vpc_cidr = var.vpc_cidr
  public_subnet_1 =var.public_subnet_web_tier_1_id_cidr
  public_subent_2 = var.public_subnet_web_tier_2_id_cidr
  private_subnet_app_tier_1 = var.private_subnet_app_tier_1_cidr
  private_subnet_app_tier_2 =var.private_subnet_app_tier_2_cidr
  ptivate_subnet_data_tier_1 = var.private_subnet_data_tier_1_cidr
  private_subnet_data_tier_2 = var.private_subnet_data_tier_2_cidr
}

#create nat gateways
module "nat_gateway" {
  source = "./modules/nat-gateway"
public_subnet_web_tier_1_id     = module.vpc.public_subnet_web_tier_1_id
internet_gateway                = module.vpc.internet_gateway
public_subnet_web_tier_2_id     = module.vpc.public_subnet_web_tier_2_id
vpc_id                          = module.vpc.vpc_id
private_subnet_app_tier_1_id    =module.vpc.private_subnet_app_tier_1
private_subnet_app_tier_2_id    =module.vpc.private_subnet_app_tier_2
private_subent_data_tier_1_id   =module.vpc.private_subent_data_tier_1
private_subnet_data_tier_2_id   =module.vpc.rivate_subnet_data_tier_2
}