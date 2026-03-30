variable "vsphere_user" {

  description = "Username to get into vsphere"
  type        = string

}

variable "vsphere_password" {

  description = "Password to get into vsphere"
  type        = string

}

variable "vsphere_server" {

  description = "Address of the vcenter server"
  type        = string

}

variable "vsphere_host" {

  description = "The address of the vsphere host"
  type        = string

}

variable "virtual_switch_name" {

  description = "Network to place the port group"
  type        = string
  default     = "Profos Switch"

}

variable "env_networks" {

        description = "The mapping of the networks for each environment"
        type = map(object({
		network_name = string
		vlan = number
		}))

        default = {

                default = { 
			network_name = "CYBR-4740-Project-Network-Default"
			vlan = 800
		}
                dev = { 
			network_name = "CYBR-4740-Project-Network-Dev"
			vlan = 810
		}
                prod = {
			network_name = "CYBR-4740-Project-Network-Prod"
			vlan = 820
		}

        }
}
