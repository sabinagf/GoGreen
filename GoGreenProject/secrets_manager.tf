resource "random_string" "identifier" {
  length  = 8
  special = false
  numeric = false
  upper   = true
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  kms_key_id  = aws_kms_key.default.id
  name        = "rds_admin"
  description = "Database credentials"
  # recovery_window_in_days = 0
  tags = {
    Name = "terraform_aws_rds_secrets_manager"
  }
}


resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = random_password.db_password.result

}

# data "aws_secretsmanager_secret" "secrets" {
#   name = aws_secretsmanager_secret.secret2.name

#   depends_on = [aws_secretsmanager_secret.secret2]
# }


# data "aws_secretsmanager_secret_version" "secret2" {
#   secret_id = aws_secretsmanager_secret.secret2.id
# }

# resource "aws_iam_user_login_profile" "password" {
#   for_each = var.sysadmin_users
#   user     = aws_iam_user.sysadmin_users[each.key].name
#   pgp_key  = "keybase:some_person_that_exists"
# }

# output "password" {
#   # value = aws_iam_user_login_profile.password.password
#   value = {
#     for user_name, login_profile in aws_iam_user_login_profile.password :
#     user_name => login_profile.password
#   }
# }