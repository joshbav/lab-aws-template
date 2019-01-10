#! /bin/bash
echo
echo YUM INSTALL OF ALL MY PACKAGES BUT DOCKER
echo
sudo yum install -y bind-utils which gawk curl gettext host iproute util-linux sed autofs nano ftp jq wget expect net-tools traceroute yum-utils device-mapper-persistent-data lvm2 which tar xz unzip curl ipset 

echo
echo INSTALLING DOCKER CE 18.09.1
echo
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce-18.09.1-3.el7 
sudo systemctl enable docker 
sudo systemctl start docker 
sudo usermod -aG docker centos 
sudo docker run hello-world

echo
echo DONE
echo



