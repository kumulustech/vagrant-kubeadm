#!/bin/bash
# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update && sudo apt-get install docker-ce=18.06.2~ce~3-0~ubuntu -y
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' | sudo tee -a /etc/docker/daemon.json

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo groupadd docker
sudo usermod -aG docker ubuntu
#noninteractive mode on python-pip install stops interactive popup hanging script
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install python-pip
sudo apt-get install joe -y
sudo pip install --upgrade pip

#Setup Kubernetes
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
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
sudo mkdir /root/.kube/
sudo cp /vagrant/admin.conf /root/.kube/config
sudo kubeadm join --token=b9e6bb.6746bcc9f8ef8267 172.16.26.10:6443 --discovery-token-unsafe-skip-ca-verification

apt-get install nfs-common -y
