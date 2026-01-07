data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.34/amazon-linux-2023/arm64/standard/recommended/image_id"
}
