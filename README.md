# kubernetes-arm
Kubernetes Cluster on ARM64 SBCs

Scripts and manifests for creating a Kubernetes cluster on Rock64 SBCs.

These files are a companion for the article published on: https://medium.com/@carlosedp/https-medium-com-carlosedp-building-a-hybrid-x86-64-and-arm-kubernetes-cluster-e7f94ff6e51d-e7f94ff6e51d

To follow the original full article published on: https://medium.com/@carlosedp/building-an-arm-kubernetes-cluster-ef31032636f9 use the tree https://github.com/carlosedp/kubernetes-arm/tree/legacy.

# Network

Network: 192.168.1.0/24

Gateway: 192.168.1.254

DNS: 192.168.1.254

Router DHCP range: 192.168.1.20 - 192.168.1.200

Reserved: 192.168.1.2 - 192.168.1.19
- 192.168.1.254 - Router

Kubernetes Nodes:
- rock64master1: 192.168.1.210
- rock64node1: 192.168.1.211
- rock64node2: 192.168.1.212


MetalLB CIDR: (14)
- 192.168.1.230/28
- 192.168.1.131 - 192.168.1.144


Traefik Internal Ingress IP: 192.168.1.245

Traefik External Ingress IP: 192.168.1.246


# Hosts on DNS or Local
<!-- The configuration added to DNSMasq options on router: address=/.internal.domain.com/192.168.1.245 -->
<!-- - 192.168.1.245 application.internal.peviwatt.io -->
- 192.168.1.245 dashboard.internal.peviwatt.io
- 192.168.1.245 grafana.internal.peviwatt.io
- 192.168.1.245 traefik.internal.peviwatt.io
- 192.168.1.245 scope.internal.peviwatt.io
<!-- - 192.168.1.245 traefik-ext.internal.peviwatt.io -->
<!-- - 192.168.1.246 consul.internal.peviwatt.io -->
<!-- - 192.168.1.246 dashboard.cloud.peviwatt.io -->

# proxy ssh from Master1 to Browser (Internal)

   On your machine run: ` ssh -D "*:8080" username@sshd_server`
   
   On your browser, Network - Settings - Manual proxy configuration - SOCKS Host: localhost Port: 8080 -- Apply

   use the internal.domain.com

