resource "aws_launch_template" "this" {
  count = var.enable ? 1 : 0

  name_prefix = "${var.environment}-${var.name}-lt-"
  update_default_version = true

  instance_type = var.instance_type
  vpc_security_group_ids = var.node_sg_ids

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      delete_on_termination = true
    }
  }

  # ⚠️ 필수: EKS bootstrap
  user_data = base64encode(<<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name}
  EOF
  )

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }

  tags = var.tags
}
