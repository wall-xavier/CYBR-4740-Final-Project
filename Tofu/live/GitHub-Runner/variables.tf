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
  default     = "GitHub-Runner"

}

variable "vm_host_name" {

  description = "The hostname of the created virtual machine"
  type        = string
  default     = "github-runner"

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
  default     = "CYBR-4740-Final/Templates/github_runner_template"

}

variable "machine_count" {

  description = "The amount of machines we would like to deploy to the network"
  type        = number
  default     = 5

}

variable "vm_folder" {

  description = "The folder to keep all the project machines"
  type        = string
  default     = "CYBR-4740-Final/Machines/GitHub-Runner"

}

variable "ip_netmask" {

  description = "The netmask to use for the VM network"
  type        = number
  default     = 24

}

variable "vm_network" {
  description = "The network the host will reside on"
  type        = string
  default     = "Updating Port Group"
}

variable "vm_network1" {

  description = "The network the host will reside on"
  type        = string
  default     = "Profos-ISP Port Group"

}

variable "subnet" {

  description = "The subnet of the static interface"
  type        = string
  default     = "10.0.10.0"

}

variable "netmask" {

  description = "The cidr notation of the network"
  type        = number
  default     = 24

}

variable "ip_offset" {

  description = "How many addresses off the base should be used for the IP"
  type        = number
  default     = 6
}

variable "gateway" {

	description = "Gateway of the static network"
	type = string
	default = "10.0.10.1"

}
