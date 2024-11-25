resource "tls_private_key" "webserver-keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "webserver_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.webserver-keypair.public_key_openssh
  depends_on = [ tls_private_key.webserver-keypair ]
}

resource "local_file" "private_key" {
  filename = "${var.key_name}.pem"
  content = tls_private_key.webserver-keypair.private_key_pem
}

resource "local_file" "id_rsa_private_key" {
  filename = "~/.ssh/id_rsa"
  content = tls_private_key.webserver-keypair.private_key_pem
  provisioner "local-exec" {
    command = "chmod 400 ~/.ssh/id_rsa"
  }
}
