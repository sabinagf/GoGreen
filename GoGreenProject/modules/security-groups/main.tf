# resource "aws_security_group" "bastion_sg" {
#  description = "Application for load balancer SG"
#   vpc_id      = aws_vpc.vpc_id 

#   ingress {
#     description      = "ssh rule"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      =["0.0.0.0/0"]
#   }

#   egress {
#     description = "needs communicate to internet"
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "bastion security group"
#   }
# }

# # create security group for web.tier
# resource "aws_security_group" "web_security_group" {
#   name        = "web  security group"
#   description = "Web Tier SG"
#   vpc_id      = var.vpc_id

#   ingress {
#     description      = "http access"
#     from_port  = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks =["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "https access"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "allows ssh, webtier can be ssh in only specific group"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     security_groups  =  [aws_security_group.bastion_sg.id]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "web security group"
#   }
# }

# resource "aws_security_group" "app_sg" {
#   description = "Application Tier SG, should not be accessible to internet"
#  vpc_id = aws_vpc.vpc_id 
# ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     security_groups = [aws_security_group.web_security_group.id]

#   }
#    ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     security_groups = [aws_security_group.bastion_sg.id]

#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "app_elb_sg" {
#   description = "Application Load Balancer SG"
#    vpc_id = aws_vpc.vpc_id 
#       ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     security_groups = [aws_security_group.web_security_group.id]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "db_security_group" {
#   vpc_id = aws_vpc.vpc_id
#   ingess = {
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     security_groups = [aws_security_group.app_security_group.id]
#   }
#   egress = {
#     from_port = 0
#     to_port= 0
#     protocol ="-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "bastion_az1" {
#   ami           = "ami-0ee4f2271a4df2d7d"
#   instance_type = "t3.micro"          # Change to your desired instance type
#   key_name      = "${var.prefix}-key" # Replace with your key pair name

#   subnet_id =  aws_subnet.web_tier_1.id # Replace with your public subnet 1 ID

#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]

#   tags = {
#     Name = "BastionHost-az1"
#   }
# }


# resource "aws_instance" "bastion_az2" {
#   ami           = "ami-0ee4f2271a4df2d7d"
#   instance_type = "t3.micro"          # Change to your desired instance type
#   key_name      = "${var.prefix}-key" # Replace with your key pair name

#   subnet_id = aws_subnet.web_tier_2.id  # Replace with your public subnet 1 ID

#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]

#   tags = {
#     Name = "BastionHost-az2"
#   }
# }