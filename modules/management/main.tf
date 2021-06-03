

#resource "azurerm_automation_account" "automation" {
#  name                = var.azurerm_automation_account_name
#  location            = var.resource_group_location
#  resource_group_name = var.resource_group_name
#
#  sku_name = "Basic"
#}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}

#resource "azurerm_log_analytics_linked_service" "example" {
#  resource_group_name = var.resource_group_name
#  workspace_id        = azurerm_log_analytics_workspace.example.id
#  read_access_id      = azurerm_automation_account.automation.id
#}

data "local_file" "startup" {
  filename = var.custom_start_script
}

resource "azurerm_automation_runbook" "startup" {

  name                    = var.azurerm_automation_startup_runbook_name
  location                = var.resource_group_location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.azurerm_automation_account_name
  log_verbose             = var.azurerm_automation_startup_runbook_log_verbose
  log_progress            = var.azurerm_automation_startup_runbook_log_progress
  description             = var.azurerm_automation_startup_runbook_description
  runbook_type            = var.azurerm_automation_startup_runbook_runbook_type

  content = data.local_file.startup.content
}

resource "azurerm_automation_schedule" "startup" {
  name                    = var.startup_automation_schedule_name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.azurerm_automation_account_name
  frequency               = var.startup_automation_schedule_frequency
  interval                = var.startup_automation_schedule_interval
  timezone                = var.startup_automation_schedule_timezone
  start_time              = var.startup_automation_schedule_start_time
  description             = var.startup_automation_schedule_description
  week_days               = var.startup_automation_schedule_week_days
}

resource "azurerm_automation_job_schedule" "startup" {
  resource_group_name     = var.resource_group_name
  automation_account_name = var.azurerm_automation_account_name
  schedule_name           = var.startup_automation_schedule_name
  runbook_name            = var.azurerm_automation_startup_runbook_name

  parameters = {
    resourcegroupname = var.resource_group_name
  }
}