provider "vsphere" {

  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10

}

resource "random_uuid" "vm_id" {

  count = var.machine_count

}


resource "vsphere_folder" "vm_folder" {

  path          = "${var.vm_folder}/FreeIPA-${terraform.workspace}"
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

resource "vsphere_virtual_machine" "freeipa-server" {

  count                      = var.machine_count
  name                       = "${var.vm_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}"
  resource_pool_id           = data.vsphere_host.host.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  num_cpus                   = var.vm_cpus
  memory                     = var.vm_memory
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  scsi_type                  = data.vsphere_virtual_machine.template.scsi_type
  firmware                   = data.vsphere_virtual_machine.template.firmware
  folder                     = vsphere_folder.vm_folder.path

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
runcmd:
  - nmcli c mod "System ens160" ipv4.method static ipv4.address ${cidrhost(var.env_networks[terraform.workspace].subnet, count.index + var.ip_offset)}/${var.ip_netmask}  ifname ens160
  - nmcli c up "System ens160"
  - sleep 5
  - hostnamectl set-hostname ipa.profos-systems.com
  - ipa-server-install -r ${var.ipa_realm} -n ${var.ipa_domain_name} -p ${var.dm_password} -a ${var.admin_password} --unattended
  - systemctl restart vmtoolsd
EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}
