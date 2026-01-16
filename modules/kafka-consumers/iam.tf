######################################################
# IAM Role
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
# IAM Policy and Instance Profile
######################################################
resource "aws_iam_policy" "this" {
  name        = "${var.environment}-${var.name}-policy"
  description = "IAM policy for consumers EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:ReadData",
          "kafka-cluster:WriteData"
        ]
        Resource = "*"
      },
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

#######################################################
# Attachments
#######################################################
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

#######################################################
# Instance Profile
#######################################################
resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}-${var.name}-instance-profile"
  role = aws_iam_role.this.name
}
