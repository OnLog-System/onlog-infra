output "onlog_prod_public_ip" {
  description = "Elastic IP for onlog prod"
  value       = aws_eip.onlog_prod.public_ip
}

output "onlog_prod_instance_id" {
  description = "EC2 instance ID for onlog prod"
  value       = module.onlog_prod_ec2.instance_id
}
