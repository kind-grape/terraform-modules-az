# variables declarations that are passed in to the component module go here
# supply the actual values in terraform.tfvars within the environment folder

#variable "azurerm_linux_virtual_machine_name" {
#    type = string
#}

variable "resource_group_name" {
    type = string
}

variable "resource_group_location" {
    type = string
}

variable "resource_group_tags" {
    type = map
}
variable "vm_specific_details" {

}

#variable "azurerm_linux_virtual_machine_size" {
#    type = string
#}

variable "azurerm_linux_virtual_machine_admin_username" {
    type = string
}

variable "admin_ssh_key_username" {
    type = string
}

variable "admin_ssh_key_public_key" {
    type = string
}

variable "environment_name" {
    type = string
}

variable "vm_name_suffix" {
    type = string
}

variable "os_disk_caching" {
    type = string
}

variable "os_disk_storage_account_type" {
    type = string
}

variable "source_image_reference_publisher" {
    type = string
}

variable "source_image_reference_offer" {
    type = string
}

variable "source_image_reference_sku" {
    type = string
}

variable "source_image_reference_version" {
    type = string
}


#NIC
variable "ip_configuration_private_ip_address_allocation" {
    type = string
}

#variable "azurerm_network_interface_name" {
#    type = string
#}

variable "ip_configuration_name" {
    type = string
}
variable "azurerm_subnet_id"{
    
}
variable "backend_address_pool_id"{
    
}

variable "vm_shutdown_schedule_enabled"{

}
variable "vm_shutdown_schedule_daily_recurrence_time"{

}
variable "vm_shutdown_schedule_timezone"{

}

variable "custom_bootstrap_bash_script"{

}

variable "azurerm_application_security_group_id"{

}