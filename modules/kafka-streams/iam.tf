###############################################
# Kafka Streams IAM Policy (Wildcard)
###############################################

resource "aws_iam_policy" "kafka_streams" {
  name        = "${var.environment}-${var.name}-kafka-streams"
  description = "Kafka Streams full topic access (wildcard)"

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
            "kafka-cluster:Connect",
            "kafka-cluster:DescribeCluster",
            "kafka-cluster:DescribeTopic",
            "kafka-cluster:ReadData",
            "kafka-cluster:WriteData"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
        }
    ]
    })
}

###############################################
# Attach to existing IAM user
###############################################

resource "aws_iam_user_policy_attachment" "kafka_streams_attach" {
  user       = "rpi-ef-kafka-streams"
  policy_arn = aws_iam_policy.kafka_streams.arn
}
