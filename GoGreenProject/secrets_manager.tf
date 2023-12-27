resource "random_password" "password" {
    length = 16
    special = true 
    override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "secrets" {
  kms_key_id = aws_kms_key.default.id
  name = "rds_admin"
  description = "RDS Admin password"
  recovery_window_in_days = 30
  tags = {
    Name = "terraform_aws_rds_secrets_manager"
  }

}
resource "aws_secretsmanager_secret_version" "secrets" {
    secret_id = aws_secretsmanager_secret.secrets.id
    secret_string = random_password.password.result
  
}