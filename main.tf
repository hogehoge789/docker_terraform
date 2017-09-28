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
resource "aws_subnet" "tf-subnet-001" {
  vpc_id                  = "${aws_vpc.tf-vpc.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "tf-subnet-002" {
  vpc_id                  = "${aws_vpc.tf-vpc.id}"
  cidr_block              = "10.1.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
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

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 鍵インポート
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

# インスタンスの作成
resource "aws_instance" "tf-ec2-01" {
  ami           = "ami-4af5022c"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.tf-subnet-001.id}"
  key_name      = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.tf-sec.id}"]
  availability_zone = "ap-northeast-1a"
  root_block_device {
    volume_size = "50"
  }
  tags {
      "Name" = "terraform-001"
  }
}

resource "null_resource" "post_process-01" {
  triggers {
    instance = "${aws_instance.tf-ec2-01.public_ip}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "${aws_instance.tf-ec2-01.public_ip}"
      user        = "ec2-user"
      private_key = "${file("terraform.ppk")}"
    }
    inline = [
      "sudo sed -i -e 's/forced-commands-only/without-password/' /etc/ssh/sshd_config",
      "sudo cp -f /home/ec2-user/.ssh/authorized_keys /root/.ssh/authorized_keys",
      "sudo service sshd reload",
      "sudo sed -i -e 's/disable_root: false/disable_root: true/' /etc/cloud/cloud.cfg"
    ]
  }
}

resource "aws_instance" "tf-ec2-02" {
  ami           = "ami-4af5022c"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.tf-subnet-002.id}"
  key_name      = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.tf-sec.id}"]
  availability_zone = "ap-northeast-1c"
  root_block_device {
    volume_size = "50"
  }
  tags {
      "Name" = "terraform-002"
  }
}

resource "null_resource" "post_process-02" {
  triggers {
    instance = "${aws_instance.tf-ec2-02.public_ip}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "${aws_instance.tf-ec2-02.public_ip}"
      user        = "ec2-user"
      private_key = "${file("terraform.ppk")}"
    }
    inline = [
      "sudo sed -i -e 's/forced-commands-only/without-password/' /etc/ssh/sshd_config",
      "sudo cp -f /home/ec2-user/.ssh/authorized_keys /root/.ssh/authorized_keys",
      "sudo service sshd reload",
      "sudo sed -i -e 's/disable_root: false/disable_root: true/' /etc/cloud/cloud.cfg",
      "sudo yum -y install nginx",
      "sudo service nginx start",
      "sudo chkconfig nginx on"
    ]
  }
}

