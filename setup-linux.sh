#! /bin/bash
echo
echo SETTING SOME ENV VARIABLES FOR ALL USERS
sudo bash -c "echo \"LANG=en_US.UTF-8\" >> /etc/environment"
sudo bash -c "echo \"LANGUAGE=en_US:en\" >> /etc/environment"
sudo bash -c "echo \"LC_ALL=en_US.UTF-8\" >> /etc/environment"

echo
echo IF NTPD IS INSTALLED, REMOVING IT. INSTALLING CHRONY AND A CONFIG FILE
echo
# Will be using chrony for NTP, ntp package may not even be installed
# Default NTP in AWS works fine, but this is useful for other environments
sudo yum remove -y ntp
sudo yum install -y chrony
# Install chrony config file
sudo cp chrony.conf /etc
# No need to restart chrony since a reboot will be done

echo
echo YUM INSTALL OF MY MAIN PACKAGES
echo
sudo yum install -y epel-release yum-utils deltarpm
sudo yum update -y
# Much of this is in a base CentOS & RHEL install, but not necessarily in a container,
#  although I wouldn't necessarily install all of it in a container.
sudo yum install -y ansible autofs bash-completion binutils bind-utils bzip2 ca-certificates centos-release coreutils cpio curl device-mapper-persistent-data diffutils ethtool expect findutils ftp gawk grep gettext git gzip hardlink hostname iftop info iproute ipset iputils jq kubernetes-cli less lua lvm2 make man nano net-tools nfs-utils nload nmap openssh-clients passwd procps-ng rsync sed sudo sysstat tar tcping traceroute unzip util-linux vim wget which xz     
echo

echo
echo ADDING ALIASES TO /ETC/BASHRC
echo
# These are just my personal preferences
sudo bash -c "echo \"alias s='sudo systemctl' j='journalctl' k='kubectl'\" >>/etc/bashrc"
echo

echo
echo INSTALLING ONESHOT SYSTEMD UNIT WHICH INSTALLS & UPDATES KERNEL HEADERS
echo
sudo cp install-kernel-headers.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable install-kernel-headers 
# Not going to run it, because after reboot the new kernel will be loaded then this will be ran

echo
echo INSTALLING 6 HOUR SYSTEMD TIMER TO SHUTDOWN SYSTEM, TO LIMIT OUR CLOUD SPEND
echo IN THE CASE OF FORGETTING TO SHUT DOWN INSTANCES
echo
sudo cp shutdown-timer.timer /etc/systemd/system
sudo cp shutdown-via-timer.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable shutdown-timer.timer
sudo systemctl start shutdown-timer.timer
sudo systemctl status shutdown-timer.timer
echo

echo
echo INSTALLING DOCKER CE 18.09.1
echo
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#older version: docker-ce-17.12.1.ce-1.el7.centos.x86_64
sudo yum install -y docker-ce-18.09.1-3.el7 
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
# NOTE autocompletion is not setup. https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion
echo

#### PYTHON 3.6
#sudo yum install -y python36 python36-setuptools
## note pip is already included python36-pip
# Note python2 is still installed, and this does not symlink to python36
# This doesn't work outside of a container, not sure why
# Note pip is built into python in 3.4 and later
#sudo python36 -m ensurepip --default-pip
#pip3 -v
#sudo pip3 install --upgrade pip
# Should not be necessary because of python36-setuptools
#sudo pip3 install virtualenv
####

#### JAVA 1.8
# 1.11 = java-11-openjdk-headless
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
echo DONE, NOW REBOOT AND RUN setup-linux2.sh TO COMPLETE THIS INSTALL
echo



