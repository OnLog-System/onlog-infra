output "nat_instance_id" {
  value = try(aws_autoscaling_group.nat.instances[0], null)
}
