# resource "aws_launch_template" "this" {
#   count = var.enable ? 1 : 0

#   name_prefix = "${var.environment}-${var.name}-lt-"
#   update_default_version = true

#   image_id      = var.ami_id
#   instance_type = var.instance_type
#   key_name      = var.key_name

#   vpc_security_group_ids = var.node_sg_ids

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size           = var.root_volume_size
#       volume_type           = "gp3"
#       iops                  = 3000
#       throughput            = 125
#       delete_on_termination = true
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(
#       var.tags,
#       { Name = "${var.environment}-${var.name}-node" }
#     )
#   }

#   tags = var.tags
# }
