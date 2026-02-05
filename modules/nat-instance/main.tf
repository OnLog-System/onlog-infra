#############################################
# 1) 최신 Amazon Linux 2023 AMI 자동 검색
#############################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }
}

#############################################
# 2) NAT Instance용 ENI 생성
#############################################
resource "aws_network_interface" "nat" {
  subnet_id         = var.subnet_id
  security_groups   = [var.security_group_id]
  source_dest_check = false

  tags = merge(
    var.tags,
    { Name = "${var.environment}-nat-eni" }
  )
}

#############################################
# 3) NAT Instance용 EIP 생성 및 ENI 연결
#############################################
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${var.environment}-nat-eip" }
  )
}

resource "aws_eip_association" "nat" {
  allocation_id        = aws_eip.nat.id
  network_interface_id = aws_network_interface.nat.id
}

#############################################
# 4) Launch Template
#############################################
resource "aws_launch_template" "nat" {
  name_prefix   = "${var.environment}-nat-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  update_default_version = true

  network_interfaces {
    network_interface_id = aws_network_interface.nat.id
    device_index         = 0
  }

  user_data = base64encode(<<EOF
#!/bin/bash
set -e

yum install -y iptables-services

systemctl enable iptables
systemctl start iptables

# IP Forwarding 활성화
cat <<SYSCTL >/etc/sysctl.d/99-nat.conf
net.ipv4.ip_forward = 1
SYSCTL
sysctl --system

# 외부 인터페이스 자동 탐지
IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

# NAT (SNAT)
iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE

# Forward 허용
iptables -A FORWARD -i $IFACE -j ACCEPT
iptables -A FORWARD -o $IFACE -j ACCEPT

service iptables save
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      { Name = "${var.environment}-nat-instance" }
    )
  }
}

#############################################
# 5) AutoScaling Group (NAT = 항상 1개)
#############################################
resource "aws_autoscaling_group" "nat" {
  name               = "${var.environment}-nat-asg"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  availability_zones = [var.nat_az]

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
