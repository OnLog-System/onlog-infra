###############################################
# EC2 Instance for Kafka Consumers
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

###############################################
# Kafka Streams EC2 Instance
###############################################

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu_2204_arm.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.this.name
  key_name               = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}"
      Environment = var.environment
      Role        = "kafka-consumers"
    }
  )
}
