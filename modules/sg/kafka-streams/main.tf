resource "aws_security_group" "kafka_streams" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Kafka Streams Security Group"
  vpc_id      = var.vpc_id

  tags = var.tags
}