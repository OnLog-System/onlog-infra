resource "aws_launch_template" "this" {
  count = var.enable ? 1 : 0

  name_prefix = "${var.environment}-${var.name}-lt-"
  update_default_version = true

  instance_type = var.instance_type
  vpc_security_group_ids = var.node_sg_ids

  user_data = base64encode(<<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.cluster_name}

--==MYBOUNDARY==--
EOF
  )

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

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      { Name = "${var.environment}-${var.name}-node" }
    )
  }

  tags = var.tags
}
