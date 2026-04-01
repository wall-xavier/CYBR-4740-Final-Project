variable "username" {

  type = string

}

variable "password" {

  type = string

}

variable "vcenter_server" {

  type = string

}

variable "setup_username" {

  type = string

}

variable "setup_password" {

  type = string

}

variable "vm_name" {

  type    = string
  default = "github_runner_template"
}

variable "vm_guest_os_type" {

  type    = string
  default = "rhel9_64Guest"

}

variable "datastore" {

  type    = string
  default = "datastore1"

}

variable "cpu_count" {

  type    = number
  default = 4

}

variable "ram_size" {

  type    = number
  default = 8192

}

variable "disk_size" {

  type    = number
  default = 256000

}

variable "thin_provisioned" {

  type    = bool
  default = true

}

variable "iso_path" {

  type    = list(string)
  default = ["[datastore1] ISOS/rhel-9.7-x86_64-boot.iso"]

}

variable "boot_commands" {

  type = list(string)
  default = [
    "c",
    "<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=RHEL-9-7-0-BaseOS-x86_64 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/github.cfg quiet<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
  "boot<enter>"]
}

variable "RHEL_ACTIVATION_KEY" {

  type = string

}

variable "REDHAT_ORGID" {

  type = string

}

variable "network_name" {

  type    = string
  default = "Updating Port Group"

}

variable "network_card_type" {

  type    = string
  default = "vmxnet3"

}

variable "post_install_script" {

  type    = string
  default = "Scripts/github_setup.sh"

}

variable "template" {

  type    = bool
  default = true

}

variable "http_directory" {

  type    = string
  default = "Scripts"

}

variable "firmware" {

  type    = string
  default = "efi"

}

variable "vm_folder" {

  type    = string
  default = "CYBR-4740-Final/Templates"

}

variable "bind_address" {

  type = string

}
