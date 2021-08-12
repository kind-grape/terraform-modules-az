############## remove when in module mode ################
# provider "azurerm" {
#   features {}
#   skip_provider_registration = true
# }
##########################################################


resource "azurerm_network_interface" "fortiweb-nic" {
  name                = "${var.fortiweb_vm_name}-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.fortiweb_front_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "fortiweb-nsg" {
  name                = "${var.fortiweb_vm_name}-nsg"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "fortiweb-nsg-rules" {
  for_each = {
    for k, r in var.fortiweb_nsg_rules : k => r
  }
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fortiweb-nsg.name
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

resource "azurerm_network_interface_security_group_association" "fortiweb" {
  network_interface_id      = azurerm_network_interface.fortiweb-nic.id
  network_security_group_id = azurerm_network_security_group.fortiweb-nsg.id
}

resource "azurerm_linux_virtual_machine" "fortiweb" {
  name                            = var.fortiweb_vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.resource_group_location
  size                            = "Standard_D2"
  admin_username                  = var.fortiweb_username
  admin_password                  = var.fortiweb_pw
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.fortiweb-nic.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "fortinet_fw-vm"
    publisher = "fortinet"
    product   = "fortinet_fortiweb-vm_v5"
  }

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortiweb-vm_v5"
    sku       = "fortinet_fw-vm"
    version   = "latest"
  }

  #custom_data = filebase64("init.sh")
  depends_on = [azurerm_managed_disk.fortiweb_data_disk,]
}

resource "azurerm_managed_disk" "fortiweb_data_disk" {
  name                 = "${var.fortiweb_vm_name}-data"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.fortiweb_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "fortiweb_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.fortiweb_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.fortiweb.id
  lun                = "01"
  caching            = "ReadWrite"
}

# run commands on the fortiweb vm
resource "null_resource" "config_fortiweb" {

  connection {
    type = "ssh"
    user = var.fortiweb_username
    password = var.fortiweb_pw
    host = azurerm_linux_virtual_machine.fortiweb.private_ip_address
  }

  provisioner "remote-exec" {
  #script = "fortiweb_script"
  inline = [
    "config system admin",
    "edit admin",
    "set password \"${var.fortiweb_pw}\"",
    "end"
  ]
  }
}
