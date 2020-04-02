# Commands Guideline to follow

Important: clone this project on Rock64Master1 to run the scripts and manifests files.

## Step 1 - Initial Configurations

Initial setup to prepare individual hosts 

Download image from official [ayufan-rock64](https://github.com/ayufan-rock64/linux-build/releases/)

Choose Lastest release, example `stretch-minimal-rock64-0.9.14-1159-arm64.img.xz`

Initial update

    > sudo apt-get update -y && sudo apt-get dist-upgrade -y

Force to use DNS nameservers

    > sudo nano /etc/resolvconf/resolv.conf.d/base
        
	nameserver 1.1.1.1
	nameserver 1.0.0.1

    > sudo resolvconf -u

Update system time zone

    > sudo timedatectl set-timezone Europe/Lisbon

Create new user and remove default user rock64

    > sudo adduser lclt

    > sudo visudo
	
	root    ALL=(ALL:ALL) ALL
	lclt	ALL=(ALL:ALL) ALL

Exit the terminal and login again on new user

Delete default user rock64 and kill running process if needed (sudo kill proccessID)

    > sudo deluser rock64

Do this again on the next node (Master1, Node1, Node2)


## Step 2 - DNS & Kubernetes setup

Follow the official tutorial [Building an ARM Kubernetes Cluster](https://itnext.io/building-an-arm-kubernetes-cluster-ef31032636f9) but ensure to use all of the dedicated scripts and gidelines of this GitHub page.

- [Basic configuration](https://github.com/luislclt/kubernetes-arm/blob/master/Rock64_Install.md)
- [Install Docker/Kubernetes utilities](https://github.com/luislclt/kubernetes-arm/blob/master/install_container_service.sh)

Configure DNS Domain or Static Hosts

    - NameCheap:
        - Initial guideline to create account and setup domains (A + Dynamic Domain)
	- DDCLIENT to auto renew my Router External IPv4 (not supporting IPv6 for now)

    - Static hosts (Use the example [Hosts DNS local](https://github.com/luislclt/kubernetes-arm/blob/master/README.md))

Kubernetes Deployment on Rock64Master1:

    > sudo kubeadm init
    
    Copy and save the kubedam join command !!
    
    After kubeadm init is finished:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config    
	
    Taint the master node so application pods can run on it too

	(Validate this, maybe change tain config on the next tutorial)

	kubectl taint nodes --all node-role.kubernetes.io/master-


Kubernetes Deployment on Rock64Node's:

    Join with Rock64Master1 saved command before (Get the command from kubeadm init command on Rock64Master1)

	kubeadm join --token secret.yourtoken (....)
	

In case of a failure you maybe need to reset all nodes and start Kubernetes again

    Drain and delete the nodes (for each node you have)

	kubectl drain kubenode1 --delete-local-data --force --ignore-daemonsets
	kubectl delete node kubenode1

    Reset the deployment
    
	sudo kubeadm reset

    On each node

    Reset the nodes and weave
	sudo curl -L git.io/weave -o /usr/local/bin/weave
	sudo chmod a+x /usr/local/bin/weave
	sudo kubeadm reset
	sudo weave reset --force

    Clean weave binaries
	
	sudo rm /opt/cni/bin/weave-*

    Flush iptables rules on all nodes and restart Docker
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -t nat -F
	iptables -t mangle -F
	iptables -F
	iptables -X
	
    systemctl restart docker


Check if every node is connected and on the same version:

    > kubectl get nodes
    
    > uname -a
    
    > cat /etc/os-release
 
## Loadbalancer and Ingress

MetalLB 

 is the Kubernetes Load Balancer, check the official website [configurations](https://metallb.universe.tf/installation/).

 For installation and configuration, run the script `install_metallb.sh` and deploy the manifest `kubectl apply -f metallb-conf.yaml` from [1-MetalLB](https://github.com/luislclt/kubernetes-arm/tree/master/1-MetalLB).

Traefik 

 is and ingress controller that can act as a reverse proxy/loadbalancer on the service layer of Kubernetes.

 To create the service on Kubernetes, just run the scripts and run manifests on the [2-Traefik](https://github.com/luislclt/kubernetes-arm/tree/master/2-Traefik).


## Kubernetes storage

Do not run for now, incompleted.

[3-NFS_Storage](https://github.com/luislclt/kubernetes-arm/tree/master/3-NFS_Storage)

To be done.

## Dashboard, heapster and InfluxDB

[4-Dashboard](https://github.com/luislclt/kubernetes-arm/tree/master/4-Dashboard)

[5-Heapster-Influx]() Verify this not existes now.

To be done.

## Monitoring Stack

To be done.


## Documentation/Support/Links

Important and Official Tutorial links:
    
    - [Building an ARM Kubernetes Cluster](https://itnext.io/building-an-arm-kubernetes-cluster-ef31032636f9)
    - [GitHub Kubernetes-arm Tutorial](https://github.com/carlosedp/kubernetes-arm)
    - [Rock64 Install (Adjust IPs/Hostnames/DNS to your deployment)](https://gist.github.com/carlosedp/4df3cd58a489a3c4022f97a474439b90)
    - [Install Docker/Kubernetes script](https://gist.github.com/carlosedp/0e72aab68c89ca5accc6ad9c14d11a87#file-install_container_service-sh)

In case after deployment docker stop comunicate with nodes [reset Kubernetes](https://gist.github.com/carlosedp/5040f4a1b2c97c1fa260a3409b5f14f9)

[Force DNS on resolv conf being overwritten](https://unix.stackexchange.com/questions/128220/how-do-i-set-my-dns-when-resolv-conf-is-being-overwritten)
