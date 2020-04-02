#!/bin/bash

echo "Install SBC utility packages"

sudo apt install -y \
    nfs-common \
    less \
    vim \
    ack \
    git \
    build-essential \
    iptables \
    ipset \
    pciutils \
    lshw \
    file \
    iperf3 \
    net-tools \
    lsb-release

echo "Install Docker pre-requisites"

sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

