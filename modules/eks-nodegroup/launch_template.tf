resource "aws_launch_template" "this" {
  name_prefix = "${var.environment}-${var.name}-lt-"

  update_default_version = true

  instance_type = var.instance_type

  vpc_security_group_ids = var.node_sg_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }

  tags = var.tags
}
