output "nodegroup_name" {
  value = var.enable ? aws_eks_node_group.this[0].node_group_name : null
}

# output "launch_template_id" {
#   value = var.enable ? aws_launch_template.this[0].id : null
# }
