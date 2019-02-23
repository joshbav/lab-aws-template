#! /bin/bash

echo
echo DELETING /ETC/MACHINE-ID, ADDING SYSTEMD UNIT TO REGENERATE IT ON REBOOT
echo
# NOTE: This really isn't necessary, I just do it anyhow.
# Since this will be a base image, we'll delete this file so it'll be recreated
#  when the first reboot happens, which should be in an instance booting from 
#  a clone of this image
# Not going to delete it now since we will reboot to install kernel headers
# then delete the file then, then take a snapshot  # sudo rm -f /etc/machine-id
sudo cp generate-machine-id.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable generate-machine-id.service
echo

echo
echo UINSTALLING POSTFIX
echo
# Why is it even installed by default in CentOS?
sudo yum remove -y postfix
echo

#### EXCLUDED FROM THIS SCRIPT
## /etc/security/limits.conf
## /etc/sysctl.conf
####

echo
echo DISABLING FIREWALLD (ignore service not found errors)
echo
# Required for Kubernetes
# TODO: check if it exists then disable
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo
echo DISABLING SELINUX
echo
# For a lab Kubernetes envioronment it makes things simpler
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

echo
echo SETTING SYSCTL SETTINGS IN /ETC/SYSCTL.CONF
echo
# Required for Kubernetes
# TODO: check if it already exists, if so use sed
echo   Setting: net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# K8s requires swapoff else kublet won't start, so this should not be
# relevant
# sudo echo "vm.swappiness=10" >> /etc/sysctl.conf

echo
echo DISABLING SWAP FILE USAGE (K8S REQUIREMENT)
echo
# Required for Kubernetes
sudo swapoff -a -v

echo
echo SETTING SOME ENV VARIABLES FOR ALL USERS
echo
sudo bash -c "echo \"LANG=en_US.UTF-8\" >> /etc/environment"
#ENV LANG en_US.UTF-8
sudo bash -c "echo \"LANGUAGE=en_US:en\" >> /etc/environment"
#ENV LANGUAGE en_US:en
sudo bash -c "echo \"LC_ALL=en_US.UTF-8\" >> /etc/environment"
#ENV ENV LC_ALL en_US.UTF-8
sudo bash -c "echo \"TERM=xterm-256color\" >> /etc/environment"
#ENV TERM xterm-256color
echo

echo
echo ADDING ALIASES TO /ETC/BASHRC
echo
# These are just my personal preferences
sudo bash -c "echo \"alias s='sudo systemctl' j='journalctl' k='kubectl' kdump='kubectl get all --all-namespaces'\" >>/etc/bashrc"
# Note kdump won't show config maps, secrets, and ingress objects TODO: how to add?
echo
# Note K8s kubectl 1.14 uses -A for all name spaces

echo
echo YUM INSTALL OF MY MAIN PACKAGES
echo
sudo yum install -y epel-release yum-utils deltarpm
sudo yum makecache -y
# sudo yum update --security -y
sudo yum update -y
# Much of this is in a base CentOS & RHEL install, but not necessarily in a container,
#  although I wouldn't necessarily install all of it in a container.
sudo yum install -y ansible autofs bash-completion binutils bind-utils bzip2 ca-certificates centos-release coreutils cpio curl device-mapper-persistent-data diffutils ethtool expect findutils ftp gawk grep gettext git gzip hardlink hostname iftop info iproute ipset iputils jq kubernetes-cli less lua lvm2 make man nano net-tools nfs-utils nload nmap openssh-clients passwd procps-ng rsync sed sudo sysstat tar tcpdump tcping traceroute unzip util-linux vim wget which xz zip
# less commonly used: sudo yum install -y mc
echo

echo
echo IF NTPD IS INSTALLED, REMOVING IT. INSTALLING CHRONY AND A CONFIG FILE
echo
# Required by Kubernetes and Sysdig
# We'll be using chrony for NTP, ntpd package may not even be installed
# Default NTP in AWS works fine, but this is useful for other environments
sudo yum remove -y ntp > /dev/null 2>&1
sudo yum install -y chrony
# Install chrony config file
sudo cp chrony.conf /etc
# No need to restart chrony since a reboot will be done
echo

echo
echo INSTALLING ONESHOT SYSTEMD UNIT WHICH INSTALLS & UPDATES KERNEL HEADERS
echo
# Sometimes required by Sysdig
sudo cp install-kernel-headers.rhel.service /etc/systemd/system/install-kernel-headers.service
sudo systemctl daemon-reload
sudo systemctl enable install-kernel-headers
# Not going to run it, because after reboot the new kernel will be loaded then this will be ran
echo

echo
echo INSTALLING 6 HOUR SYSTEMD TIMER TO SHUTDOWN SYSTEM, TO LIMIT OUR CLOUD SPEND
echo   IN THE CASE OF FORGETTING TO SHUT DOWN INSTANCES
echo
sudo cp shutdown-timer.timer /etc/systemd/system
sudo cp shutdown-via-timer.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable shutdown-timer.timer
sudo systemctl start shutdown-timer.timer
sudo systemctl status shutdown-timer.timer
echo

echo
echo INSTALLING DOCKER CE 18.09.2
echo
# Obviously required by Kubernetes
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#older version: docker-ce-17.12.1.ce-1.el7.centos.x86_64
sudo yum install -y docker-ce-18.09.2-3.el7
sudo systemctl enable docker 
sudo systemctl start docker 
sudo usermod -aG docker centos 
sudo docker run hello-world
echo

echo
echo INSTALLING KUBECTL
echo
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'
sudo yum install -y kubectl
# autocompletion per https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion
sudo echo "source <(kubectl completion bash)" >> /etc/bashrc
echo

echo
echo INSTALING .VIMRC FILE TO SET VI DEFAULTS
echo
#sudo mv ~/.vimrc ~/vimrc.old > /dev/null 2>&1
sudo cp vimrc ~/.vimrc
echo

echo
echo SETTIG TIMEZONE TO BE UTC
echo
# Not required, I just have a habit of doing this
# In AWS this is the default for CentOS, but since we might not be using AWS we'll do it here
# Don't use this in a container
sudo timedatectl set-timezone UTC
echo

#### PYTHON 3.6
#sudo yum install -y python36 python36-setuptools
## note pip is already included python36-pip
# Note python2 is still installed, and this does not symlink to python36
# This doesn't work outside of a container, not sure why
#sudo python36 -m ensurepip --default-pip
#pip3 -v
#sudo pip3 install --upgrade pip
# Should not be necessary because of python36-setuptools
#sudo pip3 install virtualenv
####

#### JAVA 1.11
# 1.8 = java-1.8.0-openjdk-headless
# sudo yum install -y java-11-openjdk-headless
# java -version
## Verify this is the right version
#todo: dockerfile ENV JAVA_VERSION ????
## FOR 1.8 need to add env vars in app definition such as java_args
## note, use: java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
## https://dzone.com/articles/running-a-jvm-in-a-container-without-getting-kille
####

#echo
#echo INSTALLING TERRAFORM 0.11.11
#echo
#curl -o /tmp/terraform_0.11.11_linux_amd64.zip -sSLO https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
#sudo unzip terraform_0.11.11_linux_amd64.zip -d /usr/bin


#### sudo rm -rf /var/cache/yum
echo
echo
echo DONE. THE FOLLOWING STEPS NEED TO BE PERFORMED:
echo
echo 1. sudo reboot     This will allow the kernel headers to be loaded 
echo    by the service that was added.
echo 2. sudo rm -f /etc/machine-id
echo 3. Shutdown
echo 4. Take a snapshot and make AMI, etc.
echo
echo


