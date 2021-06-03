# Resource Group
output "az_rg" {
  description = "The azure resource group"
  value       = {
    name        = azurerm_resource_group.az_rg.name
    location    = azurerm_resource_group.az_rg.location
  }
}

# Network
output "spoke_peered_vnet_id" {
  description = "Spoke VNet provided by HUB"
  value       = azurerm_virtual_network.spoke_peered_vnet[*]
}

output "spoke_peered_vnet_subnets" {
  description = "Spoke VNet Subnet provided by HUB"
  value       = azurerm_subnet.vnet_spoke_peered_subnet[*]
}

output "application_security_groups" {
  description = "Spoke Application security groups"
  value       = azurerm_application_security_group.application_security_groups[*]
}