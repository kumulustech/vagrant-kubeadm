#!/bin/bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-get install curl \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo apt-key adv \
#               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
#               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
#echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | sudo tee /etc/apt/sources.list.d/docker.list
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install docker-engine=1.12.6-0~ubuntu-xenial -y
#sudo apt-get install docker-engine -y
sudo apt-get install kubeadm kubectl kubernetes-cni -y
sudo service docker start
sudo groupadd docker
sudo usermod -aG docker ubuntu 
sudo apt-get install python-pip -y
sudo apt-get install joe -y
sudo -H pip install --upgrade pip

#Setup Kubernetes

ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sudo sed -e "s/^.*master.*/${ADDRESS} master master.local/" -i /etc/hosts
sudo sed -e '/^.*ubuntu-xenial.*/d' -i /etc/hosts

sudo kubeadm init --api-advertise-addresses=${ADDRESS} --token=b9e6bb.6746bcc9f8ef8267
#sudo kubeadm init --skip-preflight-checks --api-advertise-addresses=${ADDRESS} --token=b9e6bb.6746bcc9f8ef8267
sleep 15
sudo kubectl apply -f /vagrant/romana-kubeadm-vagrant.yml

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
