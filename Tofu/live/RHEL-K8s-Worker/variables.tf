variable "vsphere_user" {

  description = "The username used to authenticate with vsphere"
  type        = string
}

variable "vsphere_password" {

  description = "The password used to authenticate with vsphere"
  type        = string
}

variable "vsphere_server" {

  description = "The server tofu will authenticate to"
  type        = string

}

variable "vsphere_host" {

  description = "Host the VM will reside on"
  type        = string

}

variable "vsphere_datastore" {

  description = "Name of the vsphere datastore"
  type        = string
  default     = "datastore1"

}

variable "vm_name" {

  description = "The name of the created virtual machine"
  type        = string
  default     = "RHEL-Worker"

}

variable "vm_host_name" {

  description = "The hostname of the created virtual machine"
  type        = string
  default     = "rhel-worker"

}

variable "vm_domain_name" {

  description = "The domain name of the created virtual machine"
  type        = string
  default     = "profos-systems.com"

}

variable "vm_cpus" {

  description = "Number of virtual CPUs that will be allocated to the VM"
  type        = number
  default     = 2

}

variable "vm_memory" {

  description = "Amount of memory the VM will be allocated"
  type        = number
  default     = 8192

}

variable "vm_template" {

  description = "Template for OpenTofu to clone"
  type        = string
  default     = "CYBR-4740-Final/Templates/rhel_worker_template"

}

variable "vm_network" {

  description = "The network where the host will reside"
  type        = string
  default     = "CYBR-4740-Port-Group"

}

variable "machine_count" {

  description = "The amount of machines we would like to deploy to the network"
  type        = number
  default     = 3

}

variable "vm_folder" {

  description = "The folder to keep all the project machines"
  type        = string
  default     = "CYBR-4740-Final/Machines/RHEL-Worker"

}

variable "base_address" {

  description = "The base address for the loop to create the ip addressing scheme"
  type = string
  default = "172.16.1.0/24"

}

variable "ip_gateway" {

  description = "The IP gateway to use for the machine"
  type = string
  default = "172.16.1.254"

}

variable "ip_netmask" {

  description = "The netmask to use for the VM network"
  type = number
  default = 24

}
