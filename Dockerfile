# CentOSの最新版を使う
FROM centos:latest
MAINTAINER ueno.k

ENV TERRAFORM_VERSION=0.10.0

# Terraformインストール
RUN set -x && \
    yum install -y wget && \
    yum install -y unzip && \
    cd /usr/local/bin/ && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    export PATH=$PATH:/usr/local/bin/ && \
    mkdir /etc/terraform

# Terraform初期設定
WORKDIR /etc/terraform
ADD main.tf /etc/terraform/
ADD terraform.tfvars /etc/terraform/
RUN terraform init

CMD [ "/bin/bash" ]
