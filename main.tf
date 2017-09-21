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

# VPCの作成
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.1.0.0/16"
}

# IGWの作成 + VPCへアタッチ
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = "${aws_vpc.tf-vpc.id}"
}

# rootテーブルの作成
resource "aws_route" "tf-internet_access" {
  route_table_id         = "${aws_vpc.tf-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.tf-igw.id}"
}

# サブネットの作成
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.tf-vpc.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
}


# EC2用セキュリティグループの作成(SSH and HTTP)
resource "aws_security_group" "tf-sec" {
  name        = "terraform_sec"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.tf-vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# インスタンスの作成
resource "aws_instance" "tf-aws" {
  ami           = "ami-4af5022c"
  instance_type = "t2.small"
}