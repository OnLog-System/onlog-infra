resource "aws_key_pair" "admin_bastion_labpc" {
  key_name   = "dev-admin-bastion-labpc"
  public_key = var.admin_bastion_public_key_yoonseok_labpc
}

resource "aws_key_pair" "admin_bastion_notepc" {
  key_name   = "dev-admin-bastion-notepc"
  public_key = var.admin_bastion_public_key_yoonseok_notepc
}
