output "virtual_machine_name" {

  description = "The name of the created virtual machine"
  value = {

    for i in range(var.machine_count) :

    vsphere_virtual_machine.rhel-worker[i].name => vsphere_virtual_machine.rhel-worker[i].default_ip_address
  }
}
