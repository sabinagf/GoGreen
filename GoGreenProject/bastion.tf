resource "aws_instance" "bastion_az1" {
  ami           =  "ami-0d9b5e9b3272cff13"
  instance_type = "t2.micro"               # Change to your desired instance type
  key_name      ="Gogreen-key" # Replace with your key pair name

  subnet_id = aws_subnet.public_subnet_az1.id  # Replace with your public subnet 1 ID

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "BastionHost_az1"
  }
}


resource "aws_instance" "bastion_az2" {
  ami           = "ami-0d9b5e9b3272cff13" 
  instance_type = "t2.micro"               # Change to your desired instance type
  key_name      ="Gogreen-key" # Replace with your key pair name

  subnet_id = aws_subnet.public_subnet_az2.id  # Replace with your public subnet 1 ID

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "BastionHost_az2"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion-security-group"
  description = "Security group for bastion host"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere for illustration purposes. Update to a specific IP or range.
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# aws ec2 run-instances \
#   --image-id ami-00a42da17ecf10bee\  # Specify the appropriate AMI ID
#   --instance-type t2.micro \           # Specify the desired instance type
#   --subnet-id aws_subnet.public_subnet_az1.id \ # Specify the ID of your public subnet
#   --key-name Gogreen-key \      # Specify the name of your EC2 key pair
#   --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=BastionHost}]' \
#   --associate-public-ip-address
