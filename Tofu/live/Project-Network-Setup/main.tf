provider "vsphere" {

  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10

}

data "vsphere_datacenter" "datacenter" {


}

data "vsphere_host" "host" {

  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

resource "vsphere_host_port_group" "pg" {

  for_each = var.env_networks
  name                = each.value.network_name
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = var.virtual_switch_name

  vlan_id = each.value.vlan

}
