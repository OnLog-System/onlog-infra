############################################
# EC2 Instance Connect - SSH Receive Policy
############################################

resource "aws_iam_policy" "eice_ssh_receive" {
  name        = "eice-ssh-receive"
  description = "Allow EC2 instances to receive SSH public keys via EICE"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ec2-instance-connect:ReceiveSSHPublicKey"
      Resource = "*"
    }]
  })
}
