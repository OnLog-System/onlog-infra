resource "aws_key_pair" "admin_bastion" {
  key_name   = "dev-admin-bastion-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
