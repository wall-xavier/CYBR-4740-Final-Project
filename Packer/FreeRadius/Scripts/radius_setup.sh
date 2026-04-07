#!/bin/bash

# Disable Firewalld Rules
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Setup Vmware tools
sudo dnf install -y open-vm-tools && sudo systemctl enable --now vmtoolsd

# Install cloud-init for further customization
sudo dnf install -y cloud-init
sudo systemctl enable cloud-init-local.service
sudo systemctl enable cloud-init.service
sudo systemctl enable cloud-config.service
sudo systemctl enable cloud-final.service

# Enable the VMware Datasource
sudo tee /etc/cloud/cloud.cfg.d/99-datasource.cfg << EOF
datasource_list: [ VMware ]
EOF

sudo cloud-init clean --logs

# Install FreeRadius
#sudo rpm --import 'https://packages.inkbridgenetworks.com/pgp/packages.networkradius.com.asc'

#echo " \
#[networkradius] \
#name=NetworkRADIUS-$releasever \
#baseurl=http://packages.inkbridgenetworks.com/freeradius-3.2/rocky/$releasever/ \
#enabled=1 \
#gpgcheck=1 \
#gpgkey=https://packages.inkbridgenetworks.com/pgp/packages.networkradius.com.asc" | sudo tee /etc/yum.repos.d/networkradius.repo

sudo yum install freeradius -y

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
