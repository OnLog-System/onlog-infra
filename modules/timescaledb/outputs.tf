output "instance_id" {
  value = length(aws_instance.this) > 0 ? aws_instance.this[0].id : null
}

output "private_ip" {
  value = length(aws_instance.this) > 0 ? aws_instance.this[0].private_ip : null
}
