# Resource Group
#output "resource_group" {
#  description = "Resource Group"
#  value       = module.azurerm_resource_group.name
#}

# Network
#output "spoke_peered_vnet" {
#  description = "Spoke VNet provided by HUB"
#  value       = module.spoke_peered_vnet.name
#}

output "lb_id" {
  description = "loab balancer_id provided by network"
  value = azurerm_lb.lb.id
}

output "backend_pool_id" {
  description = "loab balancer_id provided by network"
  value = [for pool in azurerm_lb_backend_address_pool.lb_backend_pool: pool.id]
}