provider "vsphere" {

  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10

}

locals {

  current_worker_ips = [
    for i in range(3) : cidrhost(var.env_networks[terraform.workspace].subnet, i + 2)

  ]

  worker_static = cidrhost(var.env_networks[terraform.workspace].subnet, 1)

  rendered_hosts = templatefile("${path.module}/configuration/hosts.tftpl", {
    env_name  = terraform.workspace
    master_ip = cidrhost(var.env_networks[terraform.workspace].subnet, 1)
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

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.vm_name}-${terraform.workspace}-${random_uuid.vm_id[count.index].result}"
        domain    = var.vm_domain_name
      }
      network_interface {

        ipv4_address = cidrhost(var.env_networks[terraform.workspace].subnet, count.index + var.ip_offset)
        ipv4_netmask = var.ip_netmask
      }
      ipv4_gateway = var.env_networks[terraform.workspace].gateway
    }
  }

  extra_config = {
    "guestinfo.userdata" = base64encode(<<-EOF
			#cloud-config
				write_files:
					- path: /etc/hosts
					  owner: root:root
					  permissions: '0644'
					  content: |
					    ${indent(10, local.rendered_hosts)}
				runcmd:
					- [systemctl, daemon-reload]
					- [systemctl, enable, kubelet]
					- kubeadm init --control-plane-endpoint="master01:6443" --upload-certs --apiserver-cert-extra-sans=127.0.0.1,${local.worker_static}
					- mkdir -p /home/${var.ssh_username}/.kube/
					- cp /etc/kubernetes/admin.conf /home/${var.ssh_username}/.kube/config
					- chown -R ${var.ssh_username}:${var.ssh_username} /home/${var.ssh_username}/.kube/
				EOF
    )
   "guestinfo.userdata.encoding" = "base64"
  }
}
