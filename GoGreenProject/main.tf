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
  ami           = "ami-0082110c417e4726e"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.web_tier_1.id
  # availability_zone = aws_subnet.bastion_sg.availability_zone

  tags = {
  Name = "web-instance az1" }
}

resource "aws_instance" "web_instance_2" {
  ami = "ami-0082110c417e4726e"

  instance_type = "t3.micro"
  subnet_id     = aws_subnet.web_tier_2.id
  # availability_zone = aws_subnet.public_subnet_az2.availability_zone


  tags = {
    Name = "web-instance az2"
  }
}

resource "aws_instance" "app_tier_instance1" {
  ami               = "ami-0082110c417e4726e"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.app_tier_1.id
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "app-instance az1"
  }
}

resource "aws_instance" "app_tier_instance2" {
  ami               = "ami-0082110c417e4726e"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.app_tier_2.id
  availability_zone = data.aws_availability_zones.availability_zones.names[1]


  tags = {
    Name = "app-instance az2"
  }
}

# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "db-subnet-group"
#   subnet_ids = ["aws_subnet.data_tier_1.id", "aws_subnet.data_tier_2.id"]  # Replace with your subnet IDs
# }
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
  #  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "var.default_tag"
  }
}


#Create AUTO-SCALING GROUP

resource "aws_launch_configuration" "launch" {
  name          = "launch-config"
  instance_type = "t2.micro"
  image_id      = "ami-0082110c417e4726e"
  user_data =  <<-EOF
  #!/bin/bash -ex

 {

 # Update the system

 sudo dnf -y update



 # Install MySQL Community Server

 sudo dnf -y install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

 sudo dnf -y install mysql-community-server



 # Start and enable MySQL

 sudo systemctl start mysqld

 sudo systemctl enable mysqld



 # Install Apache and PHP

 sudo dnf -y install httpd php



 # Start and enable Apache

 sudo systemctl start httpd

 sudo systemctl enable httpd

 cd /var/www/html

 sudo wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz

 sudo tar xvfz lab-app.tgz

 sudo chown apache:root /var/www/html/rds.conf.php

 } &> /var/log/user_data.log
 EOF
 


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

# resource "aws_lb" "load_balancer" {
#   name               = "load-balancer"
#   internal           = false
#   load_balancer_type = "application"

#   enable_deletion_protection = false # Set to true if you want to enable deletion protection

#   subnets = [
#     aws_subnet.web_tier_1.id,
#     aws_subnet.web_tier_2.id,

# create application load balancer
resource "aws_lb" "load_balancer" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    =  [aws_security_group.web_security_group.id]
  subnets            = [  aws_subnet.web_tier_1.id,
  aws_subnet.web_tier_2.id]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project_name}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create a listener on port 443 with forward action
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn  = aws_lb.load_balancer.arn
  port               = 443
  protocol           = "HTTPS"
  ssl_policy         = "ELBSecurityPolicy-2016-08"
  certificate_arn    = aws_acm_certificate.acm_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

    # Replace with your private subnet 1 ID

    # aws_subnet.private_app_subnet_az1.id,
    # aws_subnet.private_app_subnet_az2.id,
    # aws_subnet.private_data_subnet_az1.id,
    # aws_subnet.private_data_subnet_az2.id,
    # Replace with your private subnet 2 ID
  

#   enable_cross_zone_load_balancing = true

#   enable_http2 = true # Enable if desired

#   tags = {
#     Name = "load_balancer"
#   }
# }
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


 data "aws_caller_identity" "current" {}