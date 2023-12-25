# Create IAM groups
resource "aws_iam_group" "sysadmin_group" {
  name = "SysAdmin"
}

# Create sysadmin users
resource "aws_iam_user" "sysadmin_users" {
  for_each = var.sysadmin_users

  name = var.sysadmin_users[each.key].name
}

# Adding sysadmin users to sysadmin group
resource "aws_iam_user_group_membership" "sysadmin_group_membership" {
  for_each = var.sysadmin_users

  user  = aws_iam_user.sysadmin_users[each.key].name
  groups = [aws_iam_group.sysadmin_group.name]
}
#create DBAdmin group
resource "aws_iam_group" "dbadmin_group" {
  name = "DBAdmin"
}

#create dbadmin users
resource "aws_iam_user" "dbadmin_users" {
    for_each = var.dbadmin_users
    name = var.dbadmin_users[each.key].name
}

#adding dbadmin users to DBAdmin group
resource "aws_iam_user_group_membership" "dbadmin_group_membership" {
  for_each = var.dbadmin_users

  user  = aws_iam_user.dbadmin_users[each.key].name
  groups = [aws_iam_group.dbadmin_group.name]
}

#Creating Monitor group
resource "aws_iam_group" "monitor_group" {
    name = "Monitor"
}

# Creating monitor users
resource "aws_iam_user" "monitor_users" {
  for_each =var.monitor_users

  name = var.monitor_users[each.key].name
}

#add monitor users to monitor group
resource "aws_iam_user_group_membership" "monitor_group_membership" {
  for_each = var.monitor_users

  user  = aws_iam_user.monitor_users[each.key].name
  groups = [aws_iam_group.monitor_group.name]
}




#GIVING PERMISSIONS FOR USERS

# Attach the AdministratorAccess policy to each user
resource "aws_iam_user_policy_attachment" "sysadmin_admin_policy_attachment" {
  for_each = var.sysadmin_users

  user       = aws_iam_user.sysadmin_users[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#Attach the AmazonRDSFUllAccess policy to each user

resource "aws_iam_user_policy_attachment" "dbadmin_rds_policy_attachment" {
for_each = var.dbadmin_users

user = aws_iam_user.dbadmin_users[each.key].name
policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# #Attach the AmazonS3ReadOnlyAccess, Amazon RDSReadonlyAccess, AmazonEC2ReadOnlyAccess to each user
resource "aws_iam_user_policy_attachment" "monitor_policy_attachment_s3" {
  for_each = var.monitor_users

  user      = aws_iam_user.monitor_users[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "monitor_policy_attachment_rds" {
  for_each =var.monitor_users

  user      = aws_iam_user.monitor_users[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "monitor_policy_attachment_ec2" {
  for_each =var.monitor_users
  user      = aws_iam_user.monitor_users[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}


 #create IAM role:EC2toS3IAMRole
 resource "aws_iam_role" "ec2_to_s3_iam_role" {
  name = "EC2toS3IAMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "S3ReadOnlyPolicy"
  description = "Policy for read-only access to Amazon S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:Get*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_to_s3_policy_attachment" {
  role       = aws_iam_role.ec2_to_s3_iam_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

