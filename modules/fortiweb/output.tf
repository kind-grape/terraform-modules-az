# output "fortiweb_vm_ip" {
#   description = "fortiweb internal IP addr"
#   value       = azurerm_linux_virtual_machine.fortiweb.private_ip_address
# }
output "fortiweb_vm_ip" {
  description = "ip of the fortiweb vm"
  value       = azurerm_network_interface.fortiweb-nic.private_ip_address
}

output "fortiweb_vm_id" {
  description = "id of the fortiweb vm"
  value       = azurerm_virtual_machine.fortiweb.id
}