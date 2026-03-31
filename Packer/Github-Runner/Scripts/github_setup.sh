#!/bin/bash

# Install Packer 
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer

# Install Github tools
cd /usr/src/
mkdir actions-runner && cd actions-runner
sudo chown -R github:github actions-runner/
curl -o actions-runner-linux-x64-2.333.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.333.1/actions-runner-linux-x64-2.333.1.tar.gz
echo "18f8f68ed1892854ff2ab1bab4fcaa2f5abeedc98093b6cb13638991725cab74  actions-runner-linux-x64-2.333.1.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.333.1.tar.gz
sudo ./bin/installdependencies.sh

# Install VMware tools
sudo dnf install -y open-vm-tools && sudo systemctl enable --now vmtoolsd

# Install VMware Cloud-Init plugins
sudo dnf install -y python3-pip git
sudo pip3 install https://github.com/vmware/cloud-init-vmware-guestinfo/archive/master.zip

# Install cloud-init for further customization
sudo dnf install -y cloud-init
sudo systemctl enable cloud-init-local.service
sudo systemctl enable cloud-init.service
sudo systemctl enable cloud-config.service
sudo systemctl enable cloud-final.service

sudo tee /etc/cloud/cloud.cfg.d/99-datasource.cfg << EOF
datastore_list: [ VMware, OVF, ConfigDrive, , VMwareGuestInfo, None ]
EOF

sudo cloud-init clean --logs

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
