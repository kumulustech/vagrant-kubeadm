#!/bin/bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-get install curl \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | sudo tee /etc/apt/sources.list.d/docker.list
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install docker-engine=1.12.* -y
sudo service docker start
sudo groupadd docker
sudo usermod -aG docker ubuntu
sudo apt-get install python-pip -y
sudo apt-get install joe -y
sudo pip install --upgrade pip

#Setup Kubernetes
sudo apt-get install kubeadm=1.5.6* kubelet=1.5.6* kubectl=1.5.6* kubernetes-cni=0.5.1* -y
ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
HOSTNAME=`hostname`
sudo sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts
sudo sed -e '/^.*ubuntu-xenial.*/d' -i /etc/hosts

sudo sed -i -e 's/AUTHZ_ARGS=.*/AUTHZ_ARGS="/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload

## ## Update routing for Romana
## #sudo cat >> /etc/network/interfaces <<EOF
## #up route add -net 10.96.0.0 netmask 255.240.0.0 gw 192.168.56.10
## #EOF
## #sudo ip route add 10.96.0.0/12 via 192.168.56.10

sudo kubeadm join --token=b9e6bb.6746bcc9f8ef8267 192.168.56.10

apt-get install nfs-common -y
