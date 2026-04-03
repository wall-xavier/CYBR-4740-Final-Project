variable "vsphere_user" {

  description = "Username of the user to access the VCenter Server"
  type        = string

}

variable "vsphere_password" {

  description = "Password for the VCenter User"
  type        = string

}

variable "vsphere_server" {

  type        = string
  description = "Location of the VCenter Server"

}

variable "vsphere_datacenter" {

  description = "Name of the datacenter on the vsphere server"
  type        = string

}

variable "k8s_config_raw" {

  description = "Raw configuration pulled from R2"
  type        = string

}
