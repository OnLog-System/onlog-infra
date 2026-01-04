output "nodegroup_name" {
  value = aws_eks_node_group.this.node_group_name
}

output "launch_template_id" {
  value = aws_launch_template.this.id
}
