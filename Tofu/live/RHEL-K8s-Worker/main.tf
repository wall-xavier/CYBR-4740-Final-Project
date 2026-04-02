provider "vsphere" {

  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10

}

locals {

  current_worker_ips = [
    for i in range(3) : cidrhost(var.env_networks[terraform.workspace].subnet, i + var.ip_offset)

  ]

  rendered_hosts = templatefile("${path.module}/configuration/hosts.tftpl", {
    env_name  = terraform.workspace
    master_ip = cidrhost(var.env_networks[terraform.workspace].subnet, var.ip_offset - 1)
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

data "vsphere_virtual_machine" "template" {

  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

resource "vsphere_virtual_machine" "rhel-worker" {

  count                      = var.machine_count
  name                       = "${var.vm_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}"
  resource_pool_id           = data.vsphere_host.host.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  num_cpus                   = var.vm_cpus
  memory                     = var.vm_memory
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  scsi_type                  = data.vsphere_virtual_machine.template.scsi_type
  firmware                   = data.vsphere_virtual_machine.template.firmware
  folder                     = vsphere_folder.env_folder.path
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id   = data.vsphere_network.network.id
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
    "guestinfo.userdata" = base64encode(<<-EOF
#cloud-config
write_files:
  - path: /etc/hosts
    owner: root:root
    permissions: '0644'
    content: |
      ${indent(6, local.rendered_hosts)}
runcmd:
  - [systemctl, daemon-reload]
  - [systemctl, enable, kubelet]
  - nmcli c mod "System ens160" ipv4.method static ipv4.address ${cidrhost(var.env_networks[terraform.workspace].subnet, count.index + var.ip_offset)}/${var.ip_netmask}  ifname ens160
  - nmcli c up "System ens160"
  - sleep 5
  - hostnamectl set-hostname ${var.vm_host_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}
  - kubeadm join master01:6443 --token ${var.k8s_token} --discovery-token-unsafe-skip-ca-verification
EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}
