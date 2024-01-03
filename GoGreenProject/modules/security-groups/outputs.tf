output "bastion_security_group_id" {
    value = aws_security_group.bastion_sg.id
    }

output "web_tier_security_group_id"  {
    value = aws_security_group.web_t_security_group.id
  }
