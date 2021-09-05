output "alb_dns_name" {
  value = module.alb.dns_name
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "ec2_private_ip" {
  value = [for v in module.ec2 : v.private_ip]
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
