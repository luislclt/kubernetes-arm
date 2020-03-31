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

