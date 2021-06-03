resource "azurerm_resource_group" "az_rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.resource_group_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "spoke_peered_vnet" {
  for_each = { for vnet_spoke_peered_name in var.spoke_peered_vnets : vnet_spoke_peered_name.vnet_spoke_peered_name => vnet_spoke_peered_name }
  name                = each.value.vnet_spoke_peered_name
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = azurerm_resource_group.az_rg.location
  
  address_space       = each.value.vnet_spoke_peered_address_space

  tags                = var.vnet_spoke_peered_tags
  dns_servers         = var.vnet_dns_servers_ips
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "vnet_spoke_peered_subnet" {
  for_each = { for subnet_name in var.vnet_spoke_peered_subnets : subnet_name.vnet_spoke_peered_subnet_name => subnet_name }
  name                 = each.value.vnet_spoke_peered_subnet_name
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_peered_vnet[each.value.vnet_name].name
  address_prefixes     = each.value.vnet_spoke_peered_subnet_address_prefixes
}

resource "azurerm_route_table" "vnet_spoke_peered_rt" {
  for_each = { for table in var.vnet_spoke_peered_rt_tables : table.vnet_spoke_peered_rt_name => table }
  name                = each.value.vnet_spoke_peered_rt_name
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = azurerm_resource_group.az_rg.location
  tags                = each.value.vnet_spoke_peered_rt_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_route" "route" {
  for_each = {
      for k, r in var.vnet_spoke_peered_rt_routes : k => r
      if contains(keys(r), "VirtualAppliance")
    }
    name                    = each.value.route_name
    resource_group_name     = azurerm_resource_group.az_rg.name
    route_table_name        = azurerm_route_table.vnet_spoke_peered_rt[each.value.rt_name].name
    address_prefix          = each.value.address_prefix
    next_hop_type           = each.value.next_hop_type
    next_hop_in_ip_address  = each.value.next_hop_in_ip_address
}

resource "azurerm_route" "routeNVA" {
    for_each = {
      for k, r in var.vnet_spoke_peered_rt_routes : k => r
      if contains(keys(r), "nonVirtualAppliance")
    }
    name                    = each.value.route_name
    resource_group_name     = azurerm_resource_group.az_rg.name
    route_table_name        = azurerm_route_table.vnet_spoke_peered_rt[each.value.rt_name].name
    address_prefix          = each.value.address_prefix
    next_hop_type           = each.value.next_hop_type
}

resource "azurerm_subnet_route_table_association" "vnet_spoke_peered_rt_assoc" {
  for_each = { for subnet_name in var.vnet_spoke_peered_subnets : subnet_name.vnet_spoke_peered_subnet_name => subnet_name }
  subnet_id      = azurerm_subnet.vnet_spoke_peered_subnet[each.key].id
  route_table_id = azurerm_route_table.vnet_spoke_peered_rt[each.value.rt_name].id
}

resource "azurerm_application_security_group" "application_security_groups" {
  for_each = { for asg_name in var.application_security_groups : asg_name.application_security_group_name => asg_name }
  name                = each.value.application_security_group_name
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "vnet_spoke_peered_nsg" {
  for_each = { for vnet_spoke_peered_nsg_name in var.spoke_peered_nsgs : vnet_spoke_peered_nsg_name.vnet_spoke_peered_nsg_name => vnet_spoke_peered_nsg_name }
  name                = each.value.vnet_spoke_peered_nsg_name
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = azurerm_resource_group.az_rg.location
  tags                = each.value.vnet_spoke_peered_nsg_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "vnet_spoke_peered_nsg_rule_default" {
    for_each = {
      for k, r in var.vnet_spoke_peered_nsg_rules : k => r
      if contains(keys(r), "default")
    }
    resource_group_name         = azurerm_resource_group.az_rg.name
    network_security_group_name = azurerm_network_security_group.vnet_spoke_peered_nsg[each.value.nsg_name].name
    name                        = each.value.rule_name
    priority                    = each.value.priority
    direction                   = each.value.direction
    access                      = each.value.access
    protocol                    = each.value.protocol
    source_port_range           = each.value.source_port_range
    destination_port_range      = each.value.destination_port_range
    source_address_prefix       = each.value.source_address_prefix
    destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_network_security_rule" "vnet_spoke_peered_nsg_rule_asgrules" {
    for_each = {
      for k, r in var.vnet_spoke_peered_nsg_rules : k => r
      if contains(keys(r), "asgrule")
    }
    resource_group_name                         = azurerm_resource_group.az_rg.name
    network_security_group_name                 = azurerm_network_security_group.vnet_spoke_peered_nsg[each.value.nsg_name].name
    name                                        = each.value.rule_name
    priority                                    = each.value.priority
    direction                                   = each.value.direction
    access                                      = each.value.access
    protocol                                    = each.value.protocol
    source_port_range                           = each.value.source_port_range
    destination_port_ranges                     = each.value.destination_port_ranges
    source_application_security_group_ids       = [azurerm_application_security_group.application_security_groups[each.value.source_application_security_group_ids].id]
    destination_application_security_group_ids  = [azurerm_application_security_group.application_security_groups[each.value.destination_application_security_group_ids].id]
}


resource "azurerm_network_security_rule" "vnet_spoke_peered_nsg_rule_incomingrules" {
    for_each = {
      for k, r in var.vnet_spoke_peered_nsg_rules : k => r
      if contains(keys(r), "incomingrule")
    }
    resource_group_name                         = azurerm_resource_group.az_rg.name
    network_security_group_name                 = azurerm_network_security_group.vnet_spoke_peered_nsg[each.value.nsg_name].name
    name                                        = each.value.rule_name
    priority                                    = each.value.priority
    direction                                   = each.value.direction
    access                                      = each.value.access
    protocol                                    = each.value.protocol
    source_port_range                           = each.value.source_port_range
    destination_port_ranges                     = each.value.destination_port_ranges
    source_address_prefix                       = each.value.source_address_prefix
    destination_application_security_group_ids  = [azurerm_application_security_group.application_security_groups[each.value.destination_application_security_group_ids].id]
}

resource "azurerm_network_security_rule" "vnet_spoke_peered_nsg_rule_apim" {
    for_each = {
      for k, r in var.vnet_spoke_peered_nsg_rules : k => r
      if contains(keys(r), "apim")
    }
    resource_group_name         = azurerm_resource_group.az_rg.name
    network_security_group_name = azurerm_network_security_group.vnet_spoke_peered_nsg[each.value.nsg_name].name
    name                        = each.value.rule_name
    priority                    = each.value.priority
    direction                   = each.value.direction
    access                      = each.value.access
    protocol                    = each.value.protocol
    source_port_range          = each.value.source_port_range
    destination_port_ranges      = each.value.destination_port_ranges
    source_address_prefix       = each.value.source_address_prefix
    destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_subnet_network_security_group_association" "vnet_spoke_peered_nsg_assoc" {
  for_each = { for subnet_name in var.vnet_spoke_peered_subnets : subnet_name.vnet_spoke_peered_subnet_name => subnet_name }
  subnet_id                 = azurerm_subnet.vnet_spoke_peered_subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.vnet_spoke_peered_nsg[each.value.nsg_name].id
}

resource "azurerm_dns_zone" "public" {
  for_each = { for name in var.dns_zones : name.name => name }
  name = each.value.name
  resource_group_name = var.resource_group_name
  
  dynamic "soa_record" {
    iterator = pub
    for_each = each.value.soa_records
    content {
      email = pub.value.email
      host_name = pub.value.host_name
      refresh_time = pub.value.refresh_time
      retry_time = pub.value.retry_time
      expire_time = pub.value.expire_time
      minimum_ttl = pub.value.minimum_ttl
      serial_number = pub.value.serial_number
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
  
}

resource "azurerm_dns_cname_record" "example" {
  for_each = { for name in var.dns_cname_records : name.name => name }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.dns_zone_name].name
  resource_group_name = var.resource_group_name

  ttl                 = each.value.ttl
  record              = each.value.record
}

resource "azurerm_dns_a_record" "example" {
  for_each = { for name in var.dns_a_records : name.name => name }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.dns_zone_name].name
  resource_group_name = var.resource_group_name

  ttl                 = each.value.ttl
  records             = each.value.records
}

resource "azurerm_dns_ns_record" "example" {
  for_each = { for name in var.dns_ns_records : name.name => name }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.dns_zone_name].name
  resource_group_name = var.resource_group_name

  ttl                 = each.value.ttl
  records             = each.value.records

}