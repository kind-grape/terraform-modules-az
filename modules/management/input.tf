# variables declarations that are passed in to the component module go here
# supply the actual values in terraform.tfvars within the environment folder

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "log_analytics_workspace_name" {
    
}
variable "log_analytics_workspace_retention_in_days" {
    
}
variable "log_analytics_workspace_sku" {
    
}
variable "azurerm_automation_account_name" {
    
}
variable "azurerm_automation_startup_runbook_name" {
    
}
variable "azurerm_automation_startup_runbook_log_verbose" {

}
variable "azurerm_automation_startup_runbook_log_progress" {

}
variable "azurerm_automation_startup_runbook_description" {
    
} 
variable "azurerm_automation_startup_runbook_runbook_type" {

}
variable "startup_automation_schedule_name" {

}
variable "startup_automation_schedule_frequency" {

}
variable "startup_automation_schedule_interval" {

}
variable "startup_automation_schedule_start_time" {

}
variable "startup_automation_schedule_timezone" {
    
}
variable "startup_automation_schedule_description" {
    
}
variable "startup_automation_schedule_week_days" {

}
variable "custom_start_script" {

}
