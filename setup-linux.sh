#! /bin/bash
echo
echo SETTING SOME ENV VARIABLES FOR ALL USERS
sudo echo LANG=en_US.UTF-8 >> /etc/environment
sudo echo LANGUAGE=en_US:en >> /etc/environment
sudo echo LC_ALL=en_US.UTF-8 >> /etc/environment

echo
echo YUM INSTALL OF ALL MY PACKAGES BUT DOCKER
echo
# Much of this is in a base CentOS & RHEL install, but not necessarily in a container
sudo yum install -y epel-release yum-utils
sudo yum install -y ansible autofs bind-utils bzip2 ca-certificates coreutils cpio curl device-mapper-persistent-data diffutils ethtool expect findutils ftp gawk grep gettext git gzip hardlink hostname info iproute ipset iputils jq less lua lvm2 make man nano net-tools nfs-utils nmap openssh-clients passwd procps-ng rsync sed sudo sysstat tar tcping traceroute unzip util-linux vim wget which xz     
echo
echo INSTALLING DOCKER CE 18.09.1
echo
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce-18.09.1-3.el7 
sudo systemctl enable docker 
sudo systemctl start docker 
sudo usermod -aG docker centos 
sudo docker run hello-world

#### PYTHON 3.6
#sudo yum install -y python36-setuptools
## note pip is already included python36-pip
# This doesn't work outside of a container, not sure why
#easy_install-3.6 pip
#pip3 -v
#pip3 install --upgrade pip
#pip3 install virtualenv
####

#### JAVA 1.8
# sudo yum install -y java-1.8.0-openjdk-headless
# java -version
## Verify this is the right version
#ENV JAVA_VERSION 8u181
## need to add env vars in app definition such as java_args
## note, use: java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
## https://dzone.com/articles/running-a-jvm-in-a-container-without-getting-kille
####

#echo
#echo INSTALLING TERRAFORM 0.11.11
#echo
#curl -o /tmp/terraform_0.11.11_linux_amd64.zip -sSLO https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
#sudo unzip terraform_0.11.11_linux_amd64.zip -d /usr/bin


#### yum clean all
echo
echo DONE
echo



