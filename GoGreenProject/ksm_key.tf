resource "aws_kms_key" "default" {
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true

  tags = {
    Name = "var.default_tag"
  }
}
