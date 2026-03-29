variable "vsphere_user"{

	description = "The username used to authenticate with vsphere"
	type = string
}

variable "vsphere_password"{

	description = "The password used to authenticate with vsphere"
	type = string
}

variable "vsphere_server" {

	description = "The server tofu will authenticate to"
	type = string

}

variable "vsphere_host"{

	description = "Host the VM will reside on"
	type = string

}

variable "vsphere_datastore" {

	description = "Name of the vsphere datastore"
	type = string
	default = "datastore1"

}

variable "vm_name" {

	description = "The name of the created virtual machine"
	type = string
	default = "RHEL-Worker"

}

variable "vm_host_name" {

	description = "The hostname of the created virtual machine"
	type = string
	default = "rhel-worker"

}

variable "vm_domain_name" {

	description = "The domain name of the created virtual machine"
	type = string
	default = "profos-systems.com"

}

variable "vm_cpus" {

	description = "Number of virtual CPUs that will be allocated to the VM"
	type = number
	default = 2

}

variable "vm_memory" {

	description = "Amount of memory the VM will be allocated"
	type = number
	default = 8192

}

variable "vm_template" {

	description = "Template for OpenTofu to clone"
	type = string
	default = "rhel_worker_template"

}

variable "vm_network" {

	description = "The network where the host will reside"
	type = string
	default = "Updating Port Group"

}

variable "machine_count" {

	description = "The amount of machines we would like to deploy to the network"
	type = number
	default = 3

}
