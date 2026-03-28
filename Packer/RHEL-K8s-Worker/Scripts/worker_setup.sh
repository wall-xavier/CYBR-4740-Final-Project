#!/bin/bash

sudo dnf -y install dnf-plugins-core

# Add docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker in Systemd
sudo systemctl enable docker

# Setup Vmware tools
sudo dnf install -y open-vm-tools && sudo systemctl enable --now vmtoolsd

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
