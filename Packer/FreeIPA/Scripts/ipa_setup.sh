# Install the FreeIPA Server
sudo dnf install -y ipa-server

# Disable Firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

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

# Cleanup passwordless sudo authentication
sudo rm -r /etc/sudoers.d/packer
