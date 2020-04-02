# Rock64 Install (Adjust IPs/Hostnames/DNS to with Node)

Disable NetworkManager and DHCP Client

    sudo systemctl stop dhcpcd
    sudo systemctl stop NetworkManager
    sudo systemctl disable dhcpcd
    sudo systemctl disable NetworkManager
    sudo systemctl daemon-reload

Configure network

    sudo vi /etc/network/interfaces.d/eth0

    allow-hotplug eth0
    auto eth0
    iface eth0 inet static
        address 192.168.1.210-229
        netmask 255.255.255.0
        gateway 192.168.1.254
        dns-nameservers 192.168.1.254

Set DNS

    rm /etc/resolv.conf
    touch /etc/resolv.conf
    vi /etc/resolv.conf

    nameserver 192.168.1.254

Change Hostname

    sudo vi /etc/hosts
    sudo vi /etc/hostname
    sudo hostname newhostname

    sudo service networking restart

Disable IPv6

    sudo vi /etc/sysctl.conf

    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1
    net.ipv6.conf.eth0.disable_ipv6 = 1

    sudo sysctl -p

Add user to Sudoers:

    visudo # Add to end of file:
    rock64 ALL=(ALL) NOPASSWD:ALL

Install Docker/Kubernetes components with sudo [install_container_script.sh](https://github.com/luislclt/kubernetes-arm/blob/master/install_container_service.sh)

Add user to docker group:

    sudo usermod -aG docker $USER

Create SSH Keys

    ssh-keygen -t rsa -b 2048

Update packages
    sudo apt-get update
    sudo apt-get upgrade
