#! /bin/bash
echo
echo YUM INSTALL OF ALL BUT DOCKER
echo
sudo yum install -y bind-utils which gawk curl gettext host iproute util-linux sed autofs nano ftp jq wget expect net-tools traceroute yum-utils device-mapper-persistent-data lvm2 which tar xz unzip curl ipset 

echo
echo ADD DOCKER REPO
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo
echo INSTALL DOCKER
sudo yum install -y docker-ce-18.09.1-3.el7systemctl enable docker && sudo systemctl start docker && sudo usermod -aG docker centos && sudo docker run hello-world



