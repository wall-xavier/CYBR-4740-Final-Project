output "virtual_machine_name" {

	description = "The name of the created virtual machine"
	value = resource.vsphere_virtual_machine.rhel-worker.name
}
