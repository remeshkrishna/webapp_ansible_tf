terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
  backend "s3" {
    bucket = "ansibleproject-terraform-state"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_ami" "ubuntu-latest-ami" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  most_recent = true
  owners      = [var.image_owner]
}


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

resource "aws_security_group" "webserver-ubuntu-sg" {
  name = var.sg_name
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu-latest-ami.id
  instance_type = var.ec2_instance_type
  tags = {
    Name = var.ec2_instance_name
  }
  key_name = aws_key_pair.webserver_keypair.key_name
  security_groups = [aws_security_group.webserver-ubuntu-sg.name]
  depends_on = [ aws_key_pair.webserver_keypair, aws_security_group.webserver-ubuntu-sg ]
}

resource "local_file" "inventory_file" {
  content = templatefile("inventory_template.tftpl",{ webserver_ip = aws_instance.my_ec2.public_ip })
  filename = "inventory"
  count = var.server_type != "webserver" ? 0 : 1
}
