#!/bin/bash

echo "Container Linux installation script"
echo "This will install:"
echo " - Docker Community Edition"
echo " - Docker Compose"
echo " - Kubernetes: kubeadm, kubelet and kubectl"
echo ""

set -e

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

echo "Installing Docker."

echo “deb [arch=arm64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) stable” | \
   sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-compose docker-ce
   #docker-ce=18.06.1~ce~3–0~debian 
   #docker-ce-cli containerd.io

echo "Installing Kubernetes."

sudo apt-get update
sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
#apt-mark hold kubelet kubeadm kubectl
