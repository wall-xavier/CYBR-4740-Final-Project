#!/bin/bash

sudo dnf -y install dnf-plugins-core

# Add docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install docker
sudo dnf install -y containerd.io docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker in Systemd
sudo systemctl enable docker

# Setup Containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Ensure the CRI plugin is not disabled 
sudo sed -i 's/disabled_plugins = \[.*/disabled_plugins = \[\]/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Get Kubernetes Repo
cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

# Enabled Firewalld Rules
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Enable IP Forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl --system

# Install and enable Kubernetes
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Get Kubernetes images
sudo kubeadm config images pull

# Setup Vmware tools
sudo dnf install -y open-vm-tools && sudo systemctl enable --now vmtoolsd

# Install cloud-init for further customization
sudo dnf install -y cloud-init
sudo systemctl enable cloud-init-local.service
sudo systemctl enable cloud-init.service
sudo systemctl enable cloud-config.service
sudo systemctl enable cloud-final.service

# Enabled the VMware Datasource
sudo tee /etc/cloud/cloud.cfg.d/99-datasource.cfg << EOF
datasource_list: [ VMware ]
EOF

sudo cloud-init clean --logs

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
