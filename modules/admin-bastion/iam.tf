############################################
# IAM Role for Admin Bastion (EICE)
############################################

resource "aws_iam_role" "this" {
  name = "${var.environment}-admin-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eice_ssh" {
  role       = aws_iam_role.this.name
  policy_arn = var.eice_ssh_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}

############################################
# Data
############################################
data "aws_caller_identity" "current" {}

############################################
# EKS DescribeCluster access for Admin Bastion
############################################

resource "aws_iam_policy" "eks_describe_cluster" {
  name = "${var.environment}-eks-describe-cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "arn:aws:eks:ap-northeast-2:${data.aws_caller_identity.current.account_id}:cluster/dev-eks"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_describe_cluster" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.eks_describe_cluster.arn
}
