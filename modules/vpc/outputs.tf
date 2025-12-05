output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = var.enable_nat ? aws_nat_gateway.nat[0].id : null
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "app_private_subnets_by_az" {
  value = {
    for s in aws_subnet.private :
    s.availability_zone => s.id
    if lookup(s.tags, "subnet-type", "") == "app"
  }
}