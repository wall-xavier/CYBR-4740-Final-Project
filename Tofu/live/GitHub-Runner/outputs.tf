output "virtual_machine_name" {

  description = "The name of the created virtual machine"
  value = {

    for i in range(var.machine_count) :

    vsphere_virtual_machine.github_runner[i].name => vsphere_virtual_machine.github_runner[i].default_ip_address
  }
}
