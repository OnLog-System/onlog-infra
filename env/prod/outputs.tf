output "onlog_prod_public_ip" {
  value = module.onlog_prod_ec2.public_ip
}

output "onlog_prod_instance_id" {
  value = module.onlog_prod_ec2.instance_id
}
