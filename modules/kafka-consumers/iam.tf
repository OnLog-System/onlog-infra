######################################################
# IAM Role for Kafka Consumers EC2
######################################################
resource "aws_iam_role" "this" {
  name = "${var.environment}-${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

######################################################
# IAM Policy (Kafka Read-only + CloudWatch Logs)
######################################################
resource "aws_iam_policy" "this" {
  name        = "${var.environment}-${var.name}-policy"
  description = "IAM policy for Kafka consumers (ingest / alert)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # MSK IAM Auth (Consumer only)
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:ReadData"
        ]
        Resource = "*"
      },

      # CloudWatch Logs (optional, safe default)
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

######################################################
# Attach Policy
######################################################
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

######################################################
# Instance Profile
######################################################
resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}-${var.name}-instance-profile"
  role = aws_iam_role.this.name
}
