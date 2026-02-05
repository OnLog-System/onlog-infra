###############################################
# AMI (Ubuntu 22.04 ARM64)
###############################################
data "aws_ami" "ubuntu_2204_arm" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################################
# EC2 Instance
############################################################
resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu_2204_arm.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = false

  user_data = file("${path.module}/userdata.sh")

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

############################################################
# EBS Data Volume
############################################################
resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.this.availability_zone
  size              = var.data_volume_size
  type              = "gp3"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-data"
    }
  )
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.this.id
}
