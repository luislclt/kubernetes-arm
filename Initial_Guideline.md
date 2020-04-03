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


Kubernetes Deployment on Rock64Node's:

    Join with Rock64Master1 saved command before (Get the command from kubeadm init command on Rock64Master1)

	kubeadm join --token secret.yourtoken (....)

Check if every node is connected and on the same version:

    > kubectl get nodes
    
    > uname -a
    
    > cat /etc/os-release

Install Weave Net overlay network

	kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
	sudo curl -L git.io/weave -o /usr/local/bin/weave
	sudo chmod a+x /usr/local/bin/weave

Enable pod scheduling on Master

    Taint the master node so application pods can run on it too
    (Validate this, maybe change tain config on the next tutorial)
    
	kubectl taint nodes --all node-role.kubernetes.io/master-

Don't forget to Enable feature gate for TTL

    add the flag `- --feature-gates=TTLAfterFinished=true`

    After this, wait 5 minutes for the Master pods to restart.


Cluster Status

    kubectl get nodes

### In case of a failure

Maybe need to reset all nodes and start Kubernetes again

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
 
## Step 3 - Loadbalancer and Ingress

MetalLB 

 is the Kubernetes Load Balancer, check the official website [configurations](https://metallb.universe.tf/installation/).

 For installation and configuration, run the script `install_metallb.sh` and deploy the manifest `kubectl apply -f metallb-conf.yaml` from [1-MetalLB](https://github.com/luislclt/kubernetes-arm/tree/master/1-MetalLB).

    cd 1-MetalLB
    ./install_metallb.sh
    kubectl apply -f metallb-conf.yaml

Traefik 

 is and ingress controller that can act as a reverse proxy/loadbalancer on the service layer of Kubernetes.

 To create the service on Kubernetes, just run the scripts and run manifests on the [2-Traefik](https://github.com/luislclt/kubernetes-arm/tree/master/2-Traefik).

    cd 2-Traefik/
    ./deploy.sh

Use the external directory to deploy an external Ingress controller to dynamically generate SSL certificates from LetsEncrypt. Check this [guide]()
https://medium.com/@carlosedp/multiple-traefik-ingresses-with-letsencrypt-https-certificates-on-kubernetes-b590550280cf
 dont FORGET TO MAKE THIS TUTORIAL FIRST, NOT RUN external DIRECTORY !!!
 
     cd 2-Traefik/external
     ./deploy.sh (do not run!!)


## Step 4 - Kubernetes storage

Do not run for now, incompleted.

NFS Server

  As the Master Node serves also as the NFS server for persistent storage.

    Run only on Rock64Master1
    
    sudo apt-get install nfs-kernel-server nfs-common
    sudo systemctl enable nfs-kernel-server
    sudo systemctl start nfs-kernel-server
    
    sudo cat >> /etc/exports <<EOF
    /data/kubernetes-storage/ 192.168.1.*(rw,sync,no_subtree_check,no_root_squash)
    EOF
    
    sudo exportfs -a

NFS Storageclass

   In the [3-NFS_Storage](https://github.com/luislclt/kubernetes-arm/tree/master/3-NFS_Storage) directory are the manifests to deploy a NFS controller to provide dynamic Persistent Volumes.
   
    cd 3-NFS_Storage
    ./deploy.sh


## Step 4 - Dashboard

   In the [4-Dashboard](https://github.com/luislclt/kubernetes-arm/tree/master/4-Dashboard) directory ate the 
   
   Be ware of the dependencie on Heapster that have been discontinued. 

    cd 4-Dashboard
    ./deploy.sh

   You can use this technique to force determined pods to be ran only on certain nodes. It’s a matter of replacing the tag and the deployment.
   
    kubectl patch deployment kubernetes-dashboard -n kube-system — patch '{"spec": {"template": {"spec": {"nodeSelector": {"beta.kubernetes.io/arch": "arm64"}}}}}'


To be done !!! validate if works, updated to the next version, that works without Heapster and InfluxDB.

## Step 5 - Metrics-server

   Metrics-server is the replacement for Heapster on internal metrics. In the [5-Metrics-server](https://github.com/luislclt/kubernetes-arm/tree/master/5-Metrics-server) directory.
   
    cd 5-Metrics-server
    kubectl apply -f *

   Installing metrics-server allows kubectl to display some metrics in the command line:

    kubectl top nodes
    kubectl top pods
    
   In case of an error, check if using the kube-system pods
    
    kubectl -n kube-system top pods

    kubectl -n kube-system get pods
    kubectl get namespaces
    
## Step 6 - Helm

   In the [6-Helm](https://github.com/luislclt/kubernetes-arm/tree/master/6-Helm) directory.
   To install Helm, first the helm client is installed, after it Helm is initiated and installs the server part, Tiller into the Kubernetes server. The command first created the RBAC permissions and after initiates the server with a custom image built for ARM64. The script also tags the deployment to be scheduled on an ARM64 node.
   
   Install helm:
   
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    
   Deploy on kubernetes
    
    cd 6-Helm
    ./deploy.sh
    
   Check this latter, helm init is deprecated !!!

## Step 7 - WeaveScope

   In the [7-WeaveScope](https://github.com/luislclt/kubernetes-arm/tree/master/7-WeaveScope) directory.
   Weave Scope is a fantastic tool to visualize, monitor and inspect your cluster. You can visually go into each Pod or Container, view it’s logs, drop into the shell and much more.

    cd 7-WeaveScope
    kubectl apply -f .
  Need some future changes.

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
