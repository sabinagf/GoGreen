resource "aws_security_group" "bastion_sg" {
  description = "Application for load balancer SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "needs communicate to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion security group"
  }
}

# create security group for web.tier
resource "aws_security_group" "web_security_group" {
  name        = "web  security group"
  description = "Web Tier SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "allows ssh, webtier can be ssh in only specific group"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web security group"
  }
}

resource "aws_security_group" "app_sg" {
  description = "Application Tier SG, should not be accessible to internet"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_security_group.id]

  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "app security group"
  }
}

resource "aws_security_group" "app_elb_sg" {
  description = "Application Load Balancer SG"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "app elb group"
  }
}

resource "aws_security_group" "db_security_group" {
  vpc_id = aws_vpc.vpc.id
  ingress {

    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "db security group"
  }

}

resource "aws_instance" "bastion_az1" {
  ami           = "ami-0082110c417e4726e"
  instance_type = "t3.micro"          # Change to your desired instance type
  key_name      = "Gogreen" # Replace with your key pair name

  subnet_id = aws_subnet.web_tier_1.id # Replace with your public subnet 1 ID

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost-az1"
  }
}


resource "aws_instance" "bastion_az2" {
  ami           = "ami-0082110c417e4726e"
  instance_type = "t3.micro"          # Change to your desired instance type
  key_name      = "Gogreen" # Replace with your key pair name

  subnet_id = aws_subnet.web_tier_2.id # Replace with your public subnet 1 ID

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost-az2"
  }
}



# resource "aws_eip" "eip_for_nat_gateway_web1" {
#   vpc    = true

#   tags   = {
#     Name = "natgateway for az1 eip"
#   }
# }

# # allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
# resource "aws_eip" "eip_for_nat_gateway_az2" {
#   vpc   = true

#   tags   = {
#     Name = "nat gateway for az2 eip"
#   }
# }

# # create nat gateway in public subnet web tier az1
# resource "aws_nat_gateway" "nat_gateway_web_tier_1" {
#   allocation_id = aws_eip.eip_for_nat_gateway_web1.id
#   subnet_id     = var.public_subnet_web_tier_1_id

#   tags   = {
#     Name = "nat gateway public subnet az1"
#   }

#   # to ensure proper ordering, it is recommended to add an explicit dependency
#   # depends_on = var.internet_gateway
# }

# # create nat gateway in public subnet az2
# resource "aws_nat_gateway" "nat_gateway_web_tier_2" {
#   allocation_id = aws_eip.eip_for_nat_gateway_az2.id
#   subnet_id     = public_subnet_web_tier_2_id

#   tags   = {
#     Name =  "nat gateway public subnet az2"
#   }

#   # to ensure proper ordering, it is recommended to add an explicit dependency
#   # on the internet gateway for the vpc.
#   # depends_on = var.internet_gateway
# }

# # create private route table az1 and add route through nat gateway az1
# resource "aws_route_table" "private_route_table_az1" {
#   vpc_id            = var.vpc_id

#   route {
#     cidr_block      = "0.0.0.0/0"
#     nat_gateway_id  = aws_nat_gateway.nat_gateway_web_tier_1.id
#   }

#   tags   = {
#     Name =  "private route table az1"
#   }
# }

# # associate private app subnet az1 with private route table az1
# resource "aws_route_table_association" "private_app_subnet_az1_route_table_az1_association" {
#   subnet_id         = var.private_subnet_app_tier_1_id
#   route_table_id    = aws_route_table.private_route_table_az1
# }

# # associate private data subnet az1 with private route table az1
# resource "aws_route_table_association" "private_data_subnet_az1_route_table_az1_association" {
#   subnet_id         = private_subnet_data_tier_1_id
#   route_table_id    = aws_route_table.private_route_table_az1.id
# }

# # create private route table az2 and add route through nat gateway az2
# resource "aws_route_table" "private_route_table_az2" {
#   vpc_id            = var.vpc_id

#   route {
#     cidr_block      = ["0.0.0.0/0"]
#     nat_gateway_id  = aws_nat_gateway.nat_gateway_web_tier_2
#   }

#   tags   = {
#     Name = "private route table az2"
#   }
# }

# # associate private app subnet az2 with private route table az2
# resource "aws_route_table_association" "private_app_subnet_az2_route_table_az2_association" {
#   subnet_id         = var.private_subnet_app_tier_2_id
#   route_table_id    = aws_route_table.private_route_table_az2.id
# }

# # associate private data subnet az2 with private route table az2
# resource "aws_route_table_association" "private_data_subnet_az2_route_table_az2_association" {
#   subnet_id         = var.private_subnet_data_tier_2_id
#   route_table_id    = aws_route_table_association.private_app_subnet_az2_route_table_az2_association.id
# }
# create nat gateway in public subnet web tier az1
# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 
resource "aws_eip" "eip_for_nat_gateway_web1" {
domain = "vpc"

  tags   = {
    Name = "natgateway for az1 eip"
  }
}

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
resource "aws_eip" "eip_for_nat_gateway_az2" {
domain = "vpc"

  tags   = {
    Name = "nat gateway for az2 eip"
  }
}




resource "aws_nat_gateway" "nat_gateway_web_tier_1" {
  allocation_id = aws_eip.eip_for_nat_gateway_web1.id
  subnet_id     = aws_subnet.web_tier_1.id

  tags   = {
    Name = "nat gateway public subnet az1"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on =  [aws_nat_gateway.nat_gateway_web_tier_1]
}


# create nat gateway in public subnet az2
resource "aws_nat_gateway" "nat_gateway_web_tier_2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = aws_subnet.web_tier_2.id

  tags   = {
    Name =  "nat gateway public subnet az2"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_nat_gateway.nat_gateway_web_tier_2]
}

# create private route table az1 and add route through nat gateway az1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id            = aws_vpc.vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_web_tier_1.id
  }

  tags   = {
    Name =  "private route table az1"
  }
}

# associate private app subnet az1 with private route table az1
resource "aws_route_table_association" "private_app_subnet_az1_route_table_az1_association" {
  subnet_id         = aws_subnet.app_tier_1.id
  route_table_id    = aws_route_table.private_route_table_az1.id
}

# associate private data subnet az1 with private route table az1
resource "aws_route_table_association" "private_data_subnet_az1_route_table_az1_association" {
  subnet_id         = aws_subnet.data_tier_1.id
  route_table_id    = aws_route_table.private_route_table_az1.id
}

# create private route table az2 and add route through nat gateway az2
resource "aws_route_table" "private_route_table_az2" {
  vpc_id            = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_web_tier_2.id
  }

  tags   = {
    Name = "private route table az2"
  }
}

# associate private app subnet az2 with private route table az2
resource "aws_route_table_association" "private_app_subnet_az2_route_table_az2_association" {
  subnet_id         = aws_subnet.app_tier_2.id
  route_table_id    = aws_route_table.private_route_table_az2.id
}

# associate private data subnet az2 with private route table az2
resource "aws_route_table_association" "private_data_subnet_az2_route_table_az2_association" {
  subnet_id         = aws_subnet.data_tier_2.id
  route_table_id    = aws_route_table.private_route_table_az2.id
}