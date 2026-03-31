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

  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_network" "network1" {

  name          = var.vm_network1
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_virtual_machine" "template" {

  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

resource "vsphere_virtual_machine" "github_runner" {

  count            = var.machine_count
  name             = "${var.vm_name}-${random_uuid.vm_id[count.index].result}"
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
    "guestinfo.userdata" = base64encode(<<-EOF
#cloud-config
write_files:
  - path: /lib/systemd/system/github_runner.service
    owner: root:root
    permissions: '0644'
    content: |
      [Unit]
      Description=Manage the lifecycle of the Github runner
      After=network.target
     
      [Service]
      Type=simple
      Restart=always
      RestartSec=60
      User=github
      ExecStart=/usr/src/actions-runner/run.sh

      [Install]
      WantedBy=multi-user.target

  - path: /etc/hosts
    owner: root:root
    permissions: '0644'
    content: |
      127.0.0.1 localhost
      ::1 localhost
      ${var.vsphere_server_ip} ${var.vsphere_server}
      ${var.vsphere_host_ip}  ${var.vsphere_host}

runcmd:
  - [sudo , -u , github, /usr/src/actions-runner/config.sh, --unattended ,--url , "https://github.com/wall-xavier/CYBR-4740-Final-Project", --token ,"${var.github_token}", --name ,"${var.vm_host_name}-${random_uuid.vm_id[count.index].result}"]
  - [systemctl, start, github_runner.service]
  - [systemctl, enable, github_runner.service]
  - [nmcli, c, add, con-name, "Interal", ipv4.method, static, ipv4.address, "${cidrhost(var.subnet, count.index + var.ip_offset)}/${var.ip_netmask}", ifname, ens192, type, ethernet]
  - [hostnamectl, set-hostname, "${var.vm_host_name}-${random_uuid.vm_id[count.index].result}"]
  - [reboot]
EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}
