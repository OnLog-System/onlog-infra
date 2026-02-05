###############################################
# MSK Producer IAM Policy (Wildcard)
###############################################

resource "aws_iam_policy" "msk_producer" {
  name        = "${var.environment}-${var.name}-msk-producer"
  description = "MSK producer full topic access (wildcard)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:AlterTopic",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:WriteData",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}

###############################################
# Attach to existing IAM user
###############################################

resource "aws_iam_user_policy_attachment" "msk_producer_attach" {
  user       = "rpi-ef-msk-producer"
  policy_arn = aws_iam_policy.msk_producer.arn
}
