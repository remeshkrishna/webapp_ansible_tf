variable "image_owner" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}
variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "key_name" {
  type = string
  default = "webserver-ubuntu_keypair"
}

variable "sg_name" {
  type = string
  default = "webserver-ubuntu-sg"
}

variable "ec2_instance_name" {
  type = string
  default = "webserver-ubuntu"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_type" {
  type = string
  default = "webserver"
}