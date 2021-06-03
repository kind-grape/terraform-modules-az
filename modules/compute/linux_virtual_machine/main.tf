
resource "azurerm_network_interface" "subnet_nic" {
  for_each = { for vm in var.vm_specific_details : vm.vm_name => vm }
  name                = "${var.environment_name}${var.vm_name_suffix}${each.value.vm_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  lifecycle {
    ignore_changes = [tags]
  } 
  
  ip_configuration {
        name                          = var.ip_configuration_name
        subnet_id                     = var.azurerm_subnet_id[0][each.value.subnet_type].id
        private_ip_address_allocation = var.ip_configuration_private_ip_address_allocation
        private_ip_address            = each.value.private_ip_address
    } 
}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file(var.custom_bootstrap_bash_script)
}

resource "azurerm_linux_virtual_machine" "compute_resource" {
  for_each = { for vm in var.vm_specific_details : vm.vm_name => vm }

  name                = "${var.environment_name}${var.vm_name_suffix}${each.value.vm_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = each.value.azurerm_linux_virtual_machine_size
  admin_username      = var.azurerm_linux_virtual_machine_admin_username
  tags                = merge(var.resource_group_tags,each.value.vm_tags)
  network_interface_ids = [
    azurerm_network_interface.subnet_nic[each.key].id,
  ]

  lifecycle {
    ignore_changes = [tags]
  } 

  admin_ssh_key {
    username   = var.admin_ssh_key_username
    public_key = var.admin_ssh_key_public_key
  }

  os_disk {
    name                 = "${var.environment_name}${var.vm_name_suffix}${each.value.vm_name}-osdisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }
  plan {
    name      = var.source_image_reference_sku
    product   = var.source_image_reference_offer
    publisher = var.source_image_reference_publisher
  }
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
}

resource "azurerm_network_interface_backend_address_pool_association" "bepoolassoc" {
  for_each = {
    for k, r in var.vm_specific_details : k => r
    if contains(keys(r), "lb_enabled")
  }
  network_interface_id    = azurerm_network_interface.subnet_nic[each.value.vm_name].id
  ip_configuration_name   = var.ip_configuration_name
  backend_address_pool_id = var.backend_address_pool_id
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  for_each = { for vm in var.vm_specific_details : vm.vm_name => vm }
  virtual_machine_id      = azurerm_linux_virtual_machine.compute_resource[each.value.vm_name].id
  location                = var.resource_group_location
  enabled                 = var.vm_shutdown_schedule_enabled

  daily_recurrence_time   = var.vm_shutdown_schedule_daily_recurrence_time
  timezone                = var.vm_shutdown_schedule_timezone
  
  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }
}

resource "azurerm_network_interface_application_security_group_association" "asg_nic_association" {
    for_each = { for vm in var.vm_specific_details : vm.vm_name => vm }
  network_interface_id          = azurerm_network_interface.subnet_nic[each.key].id
  application_security_group_id = var.azurerm_application_security_group_id[0][each.value.application_security_group_type].id
}

