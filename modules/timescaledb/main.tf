###############################################
# EC2 Instance for TimescaleDB
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

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu_2204_arm.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = file("${path.module}/userdata.sh")

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}"
      Environment = var.environment
      Role        = "timescaledb"
    }
  )
}

##############################################
# Single EBS Volume for Data + WAL
##############################################
resource "aws_ebs_volume" "data" {
  size              = var.data_volume_size
  type              = "gp3"
  availability_zone = aws_instance.this.availability_zone

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}-data" }
  )
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.this.id
}
