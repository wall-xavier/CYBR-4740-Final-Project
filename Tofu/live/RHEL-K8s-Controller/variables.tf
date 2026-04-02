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
  default     = "RHEL-Controller"

}

variable "vm_host_name" {

  description = "The hostname of the created virtual machine"
  type        = string
  default     = "rhel-controller"

}

variable "vm_domain_name" {

  description = "The domain name of the created virtual machine"
  type        = string
  default     = "profos-systems.com"

}

variable "vm_cpus" {

  description = "Number of virtual CPUs that will be allocated to the VM"
  type        = number
  default     = 4

}

variable "vm_memory" {

  description = "Amount of memory the VM will be allocated"
  type        = number
  default     = 8192

}

variable "vm_template" {

  description = "Template for OpenTofu to clone"
  type        = string
  default     = "CYBR-4740-Final/Templates/rhel_controller_template"

}

variable "machine_count" {

  description = "The amount of machines we would like to deploy to the network"
  type        = number
  default     = 1

}

variable "vm_folder" {

  description = "The folder to keep all the project machines"
  type        = string
  default     = "CYBR-4740-Final/Machines/RHEL-Controller"

}

variable "ip_netmask" {

  description = "The netmask to use for the VM network"
  type        = number
  default     = 24

}

variable "env_networks" {

  description = "The mapping of the networks for each environment"
  type = map(object({
    subnet     = string
    gateway    = string
    vm_network = string
  }))
  default = {

    default = {
      subnet     = "10.0.10.0/24"
      gateway    = "10.0.10.1"
      vm_network = "Profos ISP Port Group"
    }
    dev = {
      subnet     = "172.16.1.0/24"
      gateway    = "172.16.1.1"
      vm_network = "CYBR-4740-Project-Network-Dev"
    }
    prod = {
      subnet     = "172.16.2.0/24"
      gateway    = "172.16.2.1"
      vm_network = "CYBR-4740-Project-Network-Prod"
    }

  }
}

variable "ip_offset" {

  description = "How many addresses off the base should be used for the IP"
  type        = number
  default     = 11
}

variable "ssh_username" {

  description = "Username of the user to manage the machine"
  type        = string

}

variable "k8s_token" {

  description = "Token used to allow clients to join the controller node"
  type = string

}


variable "cloudflare_account_id" {

  description = "Cloudflare Account ID"
  type = string

}

variable "cloudflare_api_key" {

  description = "Cloudflare API Key"
  type = string

}

variable "bucket_name" {

  description = "Bucket to place the Kubernetes Config"
  type = string

}

variable "internet_port_group" {

  description = "Port group for controller Internet Access"
  type = string
  default = "Updating Port Group"

}
