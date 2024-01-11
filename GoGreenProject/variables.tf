variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_web_tier_1_cidr" {}
variable "public_subnet_web_tier_2_cidr" {}
variable "private_subnet_app_tier_1_cidr" {}
variable "private_subnet_app_tier_2_cidr" {}
variable "private_subnet_data_tier_1_cidr" {}
variable "private_subnet_data_tier_2_cidr" {}

#VARIABLE FOR USERS
variable "sysadmin_users" {
  type = map(object({
    name = string
    # Add other attributes as needed
  }))
  default = {
    sysadmin1 = {
      name = "sysadmin1"
      # Add other attributes for sysadmin1
    }
    sysadmin2 = {
      name = "sysadmin2"
      # Add other attributes for sysadmin2
    }
  }
}

variable "dbadmin_users" {
  type = map(object({
    name = string
  }))
  default = {
    dbadmin1 = {
      name = "dbadmin1"
    }
    dbadmin2 = {
      name = "dbadmin2"
    }
  }
}

variable "monitor_users" {
  type = map(object({
    name = string
  }))
  default = {
    monitoruser1 = {
      name = "monitoruser1"
    }
    monitoruser2 = {
      name = "monitoruser2"
    }
    monitoruser3 = {
      name = "monitoruser3"
    }
    monitoruser4 = {
      name = "monitoruser4"
    }
  }

}

variable "keybase_username" {
  description = "Keybase username for PGP encryption"
  type        = string
  default     = "ggrhjksdf"
}
variable "aws_availability_zones" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b"]
}


variable "key" {
  type    = string
  default = "default_value" # Set your default value or leave it empty if not needed
}

# variable "delete_existing_user" {
#   description = "Set to true to delete the existing IAM user during Terraform apply."
#   type        = bool
#   default     = false
# }



#VARIABLES FOR RDS
variable "prefix" {
  type    = string
  default = "Gogreen"
}


variable "allocated_storage" {
  description = "The amount of storage to allocat"
  type        = number
  default     = 20
  sensitive   = true
}

variable "storage_type" {
  type    = string
  default = "gp2"
}
variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = number
  default     = "5.7"
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.t3.micro"
}

#   variable "default_tag" {
#     type = string
#     description = "A default tag to add to everything"
#     default = "terraform_aws_rds_secret_manager"

#route 53 variable
variable "domain_name" {
  default = "ziyotekgogreen.net"
  description = "domain name"
  type =string 
  
}

variable "record_name" {
  default = "www.ziyotekgogreen.net"
  description = "sub domain name"
  type =string
  
}