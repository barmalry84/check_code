FROM centos:centos7

ENV TF_VERSION 0.11.14

# Download terraform
RUN yum install -y unzip
RUN curl -o /tmp/terraform_${TF_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
RUN unzip /tmp/terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin/
RUN rm /tmp/terraform_${TF_VERSION}_linux_amd64.zip

# add EPEL repository
RUN yum install -y epel-release

# python & pip
RUN yum install -y python36 python36-devel python36-pip

# install dev tools
RUN yum install -y openssl-devel gcc make git vim

# use nss backend for pycurl
ENV PYCURL_SSL_LIBRARY=nss

CMD /bin/bash
