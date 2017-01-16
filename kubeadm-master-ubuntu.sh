#!/bin/bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | sudo tee /etc/apt/sources.list.d/docker.list
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install docker-engine kubeadm kubectl kubernetes-cni -y
sudo service docker start
sudo groupadd docker
sudo usermod -aG docker ubuntu 
sudo apt-get install python-pip -y
sudo pip -H install --upgrade pip

#Setup Kubernetes

ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sudo sed -e "s/^.*master.*/${ADDRESS} master master.local/" -i /etc/hosts
sudo sed -e '/^.*ubuntu-xenial.*/d' -i /etc/hosts

sudo kubeadm init --api-advertise-addresses=${ADDRESS} --token=b9e6bb.6746bcc9f8ef8267
sleep 15
sudo kubectl apply -f /vagrant/romana-kubeadm-vagrant.yml

