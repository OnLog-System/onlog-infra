output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  value = aws_vpc_endpoint.dynamodb.id
}

output "interface_endpoint_ids" {
  value = {
    for name, ep in aws_vpc_endpoint.interface :
    name => ep.id
  }
}

output "eice_id" {
  value = aws_ec2_instance_connect_endpoint.eice.id
}