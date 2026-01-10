###############################################
# MSK Producer IAM Policy
###############################################

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "msk_producer" {
  name        = "${var.environment}-${var.name}-msk-producer"
  description = "Allow producer to write to MSK topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # MSK Cluster connect
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:AlterTopic"
        ]
        Resource = "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.environment}-${var.name}/*"
      },

      # Topic write access
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:WriteData"
        ]
        Resource = "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${var.environment}-${var.name}/*/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "msk_producer_attach" {
  user       = "rpi-ef-msk-producer"
  policy_arn = aws_iam_policy.msk_producer.arn
}
