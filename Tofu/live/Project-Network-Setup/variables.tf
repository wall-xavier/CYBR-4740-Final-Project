variable "port_group_name" {

  description = "Port group to be used for the project"
  type        = string
  default     = "CYBR-4740-Port-Group"

}

variable "vlan_id" {

  description = "Vlan to use for the project"
  type        = number
  default     = 800

}

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
