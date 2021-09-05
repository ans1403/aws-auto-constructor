##### Generate Key #####

resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


##### Register Keypair #####

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = tls_private_key.default.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.default.private_key_pem}' > ./dist/${var.key_name}.pem"
  }
}
