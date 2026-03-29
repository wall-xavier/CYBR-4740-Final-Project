packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/vmware/vsphere"
    }
  }
}

source "vsphere-iso" "machine_template" {

  vcenter_server      = var.vcenter_server
  username            = var.username
  password            = var.password
  insecure_connection = true
  host                = var.vcenter_server
  vm_name             = var.vm_name
  guest_os_type       = var.vm_guest_os_type
  datastore           = var.datastore
  folder              = var.vm_folder

  CPUs = var.cpu_count
  RAM  = var.ram_size

  firmware = var.firmware

  network_adapters {
    network      = var.network_name
    network_card = var.network_card_type
  }

  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = var.thin_provisioned
  }

  iso_paths = var.iso_path

  iso_checksum = "none"

  http_bind_address = var.bind_address

  http_content = {
    "/worker.cfg" = templatefile("${path.root}/Scripts/worker.cfg", {
      key            = var.RHEL_ACTIVATION_KEY
      org            = var.REDHAT_ORGID
      setup_user     = var.ssh_username
      setup_password = var.ssh_password
    })
  }

  boot_wait    = "5s"
  boot_command = var.boot_commands

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password

  convert_to_template = var.template

}

build {

  sources = ["source.vsphere-iso.machine_template"]

  provisioner "shell" {

    script = var.post_install_script

  }

}
