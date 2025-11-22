resource "null_resource" "dev_test" {
  triggers = {
    env = "dev"
  }
}
