#!/bin/bash

sudo dnf -y install dnf-plugins-core

# Add docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install docker
sudo dnf install -y containerd.io docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker in Systemd
sudo systemctl enable docker

# Setup Containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

#Setup /etc/hosts
echo "172.16.1.1 master01" | sudo tee -a /etc/hosts
echo "172.16.1.2 worker01" | sudo tee -a /etc/hosts
echo "172.16.1.3 worker02" | sudo tee -a /etc/hosts
echo "172.16.1.4 worker03" | sudo tee -a /etc/hosts

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUC=permissive' /etc/selinux/config

# Enabled Firewalld Rules
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp

# Get Kubernetes Repo
cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

# Install and enable Kubernetes
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# Setup Vmware tools
sudo dnf install -y open-vm-tools && sudo systemctl enable --now vmtoolsd

# Install cloud-init for further customization
sudo dnf install -y cloud-init
sudo systemctl enable cloud-init-local.service
sudo systemctl enable cloud-init.service
sudo systemctl enable cloud-config.service
sudo systemctl enable cloud-final.service

sudo tee /etc/cloud/cloud.cfg.d/99-datasource.cfg << EOF
datastore_list: [ VMware, OVF, ConfigDrive, None ]
EOF

sudo cloud-init clean --logs

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
