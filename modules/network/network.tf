
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.lb_sku
  tags                = var.lb_tags
  lifecycle {
    ignore_changes = [tags]
  }
  dynamic "frontend_ip_configuration" {
    iterator = pub
    for_each = var.lb_frontend_configs
    content {
      name                          = pub.value.lb_frontend_ip_config_name
      subnet_id                     = var.lb_frontend_ip_config_subnet_id
      private_ip_address            = pub.value.private_ip_address_allocation != "Dynamic" ? pub.value.lb_frontend_ip_config_private_ip_address : null
      private_ip_address_allocation = pub.value.private_ip_address_allocation
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {

  for_each = { for lb_backend_pool_name in var.lb_backend_pools : lb_backend_pool_name.lb_backend_pool_name => lb_backend_pool_name }

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.value.lb_backend_pool_name
}

resource "azurerm_lb_probe" "lb_probe" {
  for_each = { for lb_probe_name in var.lb_probes : lb_probe_name.lb_probe_name => lb_probe_name }

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.value.lb_probe_name
  port                = each.value.lb_probe_port

}

resource "azurerm_lb_rule" "lb_rule" {
  for_each = { for lb_rule_name in var.lb_rules : lb_rule_name.lb_rule_name => lb_rule_name }

  resource_group_name     = var.resource_group_name
  loadbalancer_id         = azurerm_lb.lb.id
  name                    = each.value.lb_rule_name
  protocol                = each.value.lb_rule_protocol
  frontend_port           = each.value.lb_rule_frontend
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool[each.value.lb_backend_pool_name].id
  backend_port            = each.value.lb_rule_backend
  disable_outbound_snat   = each.value.disable_outbound_snat

  frontend_ip_configuration_name = each.value.lb_frontend_ip_config_name
}
