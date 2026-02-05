resource "aws_security_group" "kafka_consumers" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for Kafka Consumers"
  vpc_id      = var.vpc_id

  tags = var.tags
}