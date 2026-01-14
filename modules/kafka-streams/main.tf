resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

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
      Role        = "kafka-streams"
    }
  )
}
