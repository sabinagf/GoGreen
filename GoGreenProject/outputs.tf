output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_web_tier_1_id" {
  value = aws_subnet.web_tier_1.id
}

output "public_subnet_web_tier_2_id" {
  value = aws_subnet.web_tier_2.id
}

output "private_subnet_app_tier_1_id" {
  value = aws_subnet.app_tier_2.id
}

output "private_subnet_app_tier_2_id" {
  value = aws_subnet.app_tier_2.id
}

output "private_subnet_data_tier_1_id" {
  value = aws_subnet.data_tier_1.id
}

output "private_subnet_data_tier_2_id" {
  value = aws_subnet.data_tier_2.id
}

output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway
}




# output "example" {
#   value = data.aws_secretsmanager_secret.example
# }
# output "secrets" {
#   value     = data.aws_secretsmanager_secret_version.secret2.secret_string
#   sensitive = true
# }
# output "admin_users_with_mfa" {
#   value =  data.aws_iam_user.admins_with_mfa
# }