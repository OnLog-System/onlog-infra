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
# EKS Admin Access for Bastion
############################################

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterAdminPolicy"
}
