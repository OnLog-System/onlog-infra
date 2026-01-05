data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  source_dest_check      = false

  user_data = <<EOF
#!/bin/bash
dnf install -y tailscale
systemctl enable --now tailscaled

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-tailscale.conf
sysctl --system
EOF

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}" }
  )
}
