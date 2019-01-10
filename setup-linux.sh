#! /bin/bash
echo
echo YUM INSTALL OF ALL MY PACKAGES BUT DOCKER
echo
# Much of this is in a base CentOS & RHEL install, but not necessarily in a container
sudo yum install -y epel-release
sudo yum install -y \ 
ansible \
autofs\
bind-utils \ 
bzip2 \
ca-certificates \
cpio \
curl \
device-mapper-persistent-data \
diffutils \
ethtool \
expect \
findutils \
ftp \
gawk \
grep \
gettext \
git \
gzip \
hardlink \
hostname \
info \
iproute \
ipset \
iputils \
jq \
less \
lua \
lvm2 \
make \
nano \
net-tools \
nfs-utils \
openssh \
passwd \
rsync \
sed \
sudo \
tar \
traceroute \
unzip \
util-linux \
vim \
wget \
which \
xz \
yum-utils    

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



