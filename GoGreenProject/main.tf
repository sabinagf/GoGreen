# resource "aws_key_pair" "key" {
#   key_name = "${var.prefix}-key"
#   public_key = file("~/.ssh/id_ed25519.pub")

# }

#create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}


#use data source to get all avalability zones in region
data "aws_availability_zones" "availability_zones" {}


# create a public subnet az1

resource "aws_subnet" "web_tier_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_web_tier_1_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet az1"
  }
}

#create public subnet az2
resource "aws_subnet" "web_tier_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_web_tier_2_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet az2 "
  }
}

# create route table add public route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public route table"
  }
}

#associate public subnet az1 to "public route table"
resource "aws_route_table_association" "public_subent_az1_route_table_association" {
  subnet_id      = aws_subnet.web_tier_1.id
  route_table_id = aws_route_table.public_route_table.id
}


# associate public subnet az2 to "public route table"
resource "aws_route_table_association" "public_subent_az2_route_table_association" {
  subnet_id      = aws_subnet.web_tier_2.id
  route_table_id = aws_route_table.public_route_table.id
}

#create private subnet az1
resource "aws_subnet" "app_tier_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_app_tier_1_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private app subnet az1"
  }
}


#creare private app subnet az2
resource "aws_subnet" "app_tier_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_app_tier_2_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "private app subnet az2"
  }
}


#create private data subnet az1
resource "aws_subnet" "data_tier_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_data_tier_1_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private data subnet az1"
  }
}

#create private data subnet az2
resource "aws_subnet" "data_tier_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_data_tier_2_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "private data subnet az2"
  }
}

# resource "aws_db_subnet_group" "my_db_subnet_group" {
#   name       = "my-db-subnet-group"
#   subnet_ids = [aws_subnet_data_tier_2.id, aws_subnet_data_tier_2.id]
#   # Add other subnet group settings as needed
# }

# data "aws_secretsmanager_secret" "secrets" {
#   name = aws_secretsmanager_secret.secrets.name

#   depends_on = [aws_secretsmanager_secret.secrets]
# }


# data "aws_secretsmanager_secret_version" "secrets" {
#   secret_id = data.aws_secretsmanager_secret.secrets.id
# }
#Create ec2 instance
resource "aws_instance" "web_intance_1" {
  ami           = "ami-0ee4f2271a4df2d7d"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.web_tier_1.id
  # availability_zone = aws_subnet.bastion_sg.availability_zone

  tags = {
  Name = "pub ec2 instance 1" }
}

resource "aws_instance" "web_instance_2" {
  ami = "ami-0ee4f2271a4df2d7d"

  instance_type = "t3.micro"
  subnet_id     = aws_subnet.web_tier_2.id
  # availability_zone = aws_subnet.public_subnet_az2.availability_zone


  tags = {
    Name = "pub ec2 instance2"
  }
}

resource "aws_instance" "app_tier_instance1" {
  ami               = "ami-0ee4f2271a4df2d7d"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.app_tier_1.id
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "pr.ec2 instance"
  }
}

resource "aws_instance" "app_tier_instance2" {
  ami               = "ami-0ee4f2271a4df2d7d"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.app_tier_2.id
  availability_zone = data.aws_availability_zones.availability_zones.names[1]


  tags = {
    Name = "pr.ec2 instance"
  }
}



resource "aws_db_instance" "my_rds_instance" {
  identifier        = "my-database"
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  username          = "Admin"
  password          = random_password.db_password.result
  # db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  publicly_accessible = false
  storage_encrypted   = true
  multi_az            = true
  skip_final_snapshot = true

  #Add other RDS instance settings as needed

  tags = {
    Name = "var.default_tag"
  }
}


#Create AUTO-SCALING GROUP

resource "aws_launch_configuration" "launch" {
  name          = "launch-config"
  instance_type = "t2.micro"
  image_id      = "ami-0ee4f2271a4df2d7d"


  # Specify your launch configuration details here
}

resource "aws_autoscaling_group" "auto_scaling" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2
  vpc_zone_identifier = [
    aws_subnet.web_tier_1.id,
    aws_subnet.web_tier_2.id,
    aws_subnet.app_tier_1.id,
    aws_subnet.app_tier_2.id,
    aws_subnet.data_tier_1.id,
    aws_subnet.data_tier_2.id,
  ]
  launch_configuration = aws_launch_configuration.launch.id
  # Other configuration settings for the Auto Scaling group
}

# Specify additional Auto Scaling group settings here


#CREATE LOAD_BALANCER

resource "aws_lb" "load_balancer" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false # Set to true if you want to enable deletion protection

  subnets = [
    aws_subnet.web_tier_1.id,
    aws_subnet.web_tier_2.id,

    # Replace with your private subnet 1 ID

    # aws_subnet.private_app_subnet_az1.id,
    # aws_subnet.private_app_subnet_az2.id,
    # aws_subnet.private_data_subnet_az1.id,
    # aws_subnet.private_data_subnet_az2.id,
    # Replace with your private subnet 2 ID
  ]

  enable_cross_zone_load_balancing = true

  enable_http2 = true # Enable if desired

  tags = {
    Name = "load_balancer"
  }
}
#CREATE ELASTIC_IP(EIP) 
# resource "aws_eip" "elastic_ip1" {
#   instance = aws_instance.instance_az1.id # Specify the ID of the associated EC2 instance, if any
#   domain = "vpc"  # Set to true if you're working in a VPC, false for EC2-Classic

#   # Additional optional parameters
#   # associate_with_private_ip = "10.0.1.10"  # Optional: Associate the EIP with a specific private IP address
#   tags = { Name = "elastic_ip" }  # Optional: Tags for the EIP
# }

# resource "aws_eip" "elastic_ip2" {
#   instance = aws_instance.instance_az2.id # Specify the ID of the associated EC2 instance, if any
#   domain = "vpc" # Set to true if you're working in a VPC, false for EC2-Classic

#   # Additional optional parameters
#   # associate_with_private_ip = "10.0.1.10"  # Optional: Associate the EIP with a specific private IP address
#   tags = { Name = "elastic_ip" }  # Optional: Tags for the EIP
# }


