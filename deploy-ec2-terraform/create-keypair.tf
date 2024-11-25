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