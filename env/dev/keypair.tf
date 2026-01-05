resource "aws_key_pair" "admin_bastion" {
  key_name   = "dev-admin-bastion-key"
  public_key = var.admin_bastion_public_key_yoonseok
}
