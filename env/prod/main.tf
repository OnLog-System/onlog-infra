resource "null_resource" "prod_test" {
  triggers = {
    env = "prod"
  }
}
