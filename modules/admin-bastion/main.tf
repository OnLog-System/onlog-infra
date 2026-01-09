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
  iam_instance_profile = aws_iam_instance_profile.this.name

  key_name = var.key_name
  source_dest_check      = false

  user_data = <<EOF
#!/bin/bash
set -e

curl -fsSL https://tailscale.com/install.sh | sh
systemctl enable --now tailscaled

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-tailscale.conf
sysctl --system

cat <<'EOS' > /etc/systemd/system/tailscale-autoup.service
[Unit]
Description=Tailscale auto up
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
  /usr/bin/tailscale status >/dev/null 2>&1 || \
  /usr/bin/tailscale up \
    --authkey=${var.tailscale_auth_key} \
    --advertise-routes=10.0.0.0/16 \
    --hostname=dev-admin-bastion \
    --accept-routes=false \
'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOS

systemctl daemon-reload
systemctl enable tailscale-autoup
sudo systemctl start tailscale-autoup

curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
EOF

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}" }
  )
}