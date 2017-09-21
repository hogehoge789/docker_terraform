# CentOSの最新版を使う
FROM centos:latest
MAINTAINER ueno.k

# Terraformインストール
RUN set -x && \
    yum install -y wget && \
    yum install -y unzip && \
    cd /usr/local/bin/ && \
    wget https://releases.hashicorp.com/terraform/0.10.6/terraform_0.10.6_linux_amd64.zip && \
    unzip terraform_0.10.6_linux_amd64.zip && \
    export PATH=/bin/:/usr/local/bin/ && \
    mkdir /etc/terraform

# Terraform初期設定
WORKDIR /etc/terraform
ADD main.tf /etc/terraform/
ADD terraform.tfvars /etc/terraform/
RUN terraform init

CMD [ "/bin/bash" ]
