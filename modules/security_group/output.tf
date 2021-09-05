output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "ec2_bastion_security_group_id" {
  value = aws_security_group.ec2_bastion.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
