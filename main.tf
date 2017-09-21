
variable "access_key" {}
variable "secret_key" {}
variable "aws_region" {
    default = "ap-northeast-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "aws_instance" "terraform-aws" {
  ami           = "ami-4af5022c"
  instance_type = "t2.small"
}