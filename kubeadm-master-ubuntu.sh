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
sudo usermod -aG docker vagrant
#noninteractive mode on python-pip install stops interactive popup hanging script
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install python-pip
sudo apt-get install joe -y
sudo -H pip install --upgrade pip

#Setup Kubernetes
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sudo sed -e "s/^.*master.*/${ADDRESS} master master.local/" -i /etc/hosts
sudo sed -e '/^.*ubuntu-xenial.*/d' -i /etc/hosts

sudo sed -i -e 's/AUTHZ_ARGS=.*/AUTHZ_ARGS="/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload

sudo kubeadm init --apiserver-advertise-address=${ADDRESS} --token=b9e6bb.6746bcc9f8ef8267  --pod-network-cidr=192.168.0.0/16 
sleep 15
sudo mkdir -p /root/.kube/
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo mkdir -p ~vagrant/.kube
sudo cp /etc/kubernetes/admin.conf ~vagrant/.kube/config
sudo chown -R vagrant:vagrant ~vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /vagrant/

kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml

# Add storage on master and export via NFS
apt-get install nfs-kernel-server nfs-common -y
mkdir -p /var/nfs/general
mkfs.ext4 -L nfs-general /dev/sdc
echo 'LABEL=nfs-general ext4 defaults 0 0' >> /etc/fstab
echo '/var/nfs/general *(rw,sync,no_subtree_check)' >> /etc/exports
mount -a
for n in one two three four; do mkdir /var/nfs/general/${n}; done
chown -R nobody.nogroup /var/nfs/general
exportfs -a
