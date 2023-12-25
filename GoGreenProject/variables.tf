variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {} 
variable "key" {}

#VARIABLE FOR USERS
variable "sysadmin_users" {
  type = map(object({
    name     = string
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
    name= string
}))
default = {
    dbadmin1 = {
        name= "dbadmin1"
}
dbadmin2 = {
    name = "dbadmin2"
}
}
}

variable "monitor_users" {
    type = map(object({
        name=string
    }))
default = {
    monitoruser1 = {
  name = "monitoruser1"
    }
    monitoruser2 = {
        name="monitoruser2"
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
