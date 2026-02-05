############################################################
# SSH Key Pair (prod)
############################################################

resource "aws_key_pair" "onlog_prod_labpc" {
  key_name   = "onlog-prod-labpc"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIVt7NossIaYSVUwDTvPrVqG6lpX9pjHpyEzwruSWd3 kangcl1609@google.com"
}