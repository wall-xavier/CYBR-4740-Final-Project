provider "vsphere" {

  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10

}

locals {

  current_worker_ips = [
    for i in range(3) : cidrhost(var.env_networks[terraform.workspace].subnet, i + var.ip_offset + 1)

  ]

  worker_static = cidrhost(var.env_networks[terraform.workspace].subnet, var.ip_offset)

  rendered_hosts = templatefile("${path.module}/configuration/hosts.tftpl", {
    env_name  = terraform.workspace
    master_ip = cidrhost(var.env_networks[terraform.workspace].subnet, var.ip_offset)
    worker_ip = local.current_worker_ips
  })
}

resource "random_uuid" "vm_id" {

  count = var.machine_count

}

resource "vsphere_folder" "vm_folder" {

  path          = var.vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

resource "vsphere_folder" "env_folder" {

  path          = "${resource.vsphere_folder.vm_folder.path}/${terraform.workspace}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_datacenter" "datacenter" {

}

data "vsphere_host" "host" {

  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_datastore" "datastore" {

  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {

  name          = var.env_networks[terraform.workspace].vm_network
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_network" "network1" {

  name          = var.internet_port_group
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_virtual_machine" "template" {

  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

resource "vsphere_virtual_machine" "rhel-controller" {

  count            = var.machine_count
  name             = "${var.vm_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}"
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.vm_cpus
  memory           = var.vm_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware         = data.vsphere_virtual_machine.template.firmware
  folder           = vsphere_folder.env_folder.path

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

network_interface {
    
    network_id   = data.vsphere_network.network1.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

}

  

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "disk.enableUUID" = "1"
    "guestinfo.userdata" = base64encode(<<-EOF
#cloud-config
write_files:
  - path: /etc/hosts
    owner: root:root
    permissions: '0644'
    content: |
      ${indent(6, local.rendered_hosts)}
runcmd:
  - nmcli c mod "System ens160" ipv4.method static ipv4.address ${cidrhost(var.env_networks[terraform.workspace].subnet, count.index + var.ip_offset)}/${var.ip_netmask}  ifname ens160
  - nmcli c up "System ens160"
  - nmcli c add con-name "Internet" ipv4.method auto type ethernet ifname ens192
  - nmcli c up "Internet"
  - sleep 5
  - hostnamectl set-hostname ${var.vm_host_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}
  - [systemctl, daemon-reload]
  - [systemctl, enable, kubelet]
  - kubeadm init --token=${var.k8s_token} --control-plane-endpoint="master01:6443" --upload-certs --apiserver-cert-extra-sans="127.0.0.1,${local.worker_static}" --pod-network-cidr=10.244.0.0/16
  - mkdir -p "/home/${var.ssh_username}/.kube/"
  - cp /etc/kubernetes/admin.conf /home/${var.ssh_username}/.kube/config
  - chown -R ${var.ssh_username}:${var.ssh_username} /home/${var.ssh_username}/.kube/
  - CLOUDFLARE_ACCOUNT_ID=${var.cloudflare_account_id} CLOUDFLARE_API_TOKEN=${var.cloudflare_api_key} npx -y wrangler r2 object put ${var.bucket_name}/kubernetes-configuration/${terraform.workspace}/config --file=/home/${var.ssh_username}/.kube/config --remote
  - ip route add 10.0.0.0/8 via ${cidrhost(var.env_networks[terraform.workspace].subnet, 1)} dev ens160
  - ip route add 172.16.0.0/16 via ${cidrhost(var.env_networks[terraform.workspace].subnet, 1)} dev ens160
EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}
