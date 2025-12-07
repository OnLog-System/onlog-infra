resource "aws_launch_template" "nat" {
  name_prefix = "${var.environment}-nat-"
  image_id    = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
    subnet_id                   = var.subnet_id
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-nat-instance"
      }
    )
  }
}

resource "aws_autoscaling_group" "nat" {
  name                      = "${var.environment}-nat-asg"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 30

  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.nat.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-nat"
    propagate_at_launch = true
  }
}

# EIP 생성
resource "aws_eip" "nat" {
  vpc        = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip"
    }
  )
}

# EIP → NAT Instance 연결 (ASG는 instance_id를 직접 가리킬 수 없으므로)
resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.nat.id
  instance_id   = aws_autoscaling_group.nat.instances[0].id
}
