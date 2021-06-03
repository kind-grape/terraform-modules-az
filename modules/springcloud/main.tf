
resource "azurerm_spring_cloud_service" "spring" {
  name                = var.spring_cloud_service_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  sku_name             = var.spring_cloud_service_sku

  //network {
  //  app_subnet_id                           = var.acs_app_subnet_id
  //  service_runtime_subnet_id               = var.acs_service_runtime_subnet_id 
  //  //cidr_ranges                             = var.acs_cidr_ranges
  //  app_network_resource_group              = var.acs_app_network_resource_group 
  //  service_runtime_network_resource_group  = var.acs_service_runtime_network_resource_group 
  //}


  trace {
    instrumentation_key = var.instrumentation_key
    sample_rate         = var.sample_rate
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

//resource "azurerm_spring_cloud_custom_domain" "domains" {
//  for_each = { for domain_name in var.azurerm_spring_cloud_custom_domains : domain_name.domain_name => domain_name }
//
//  name                = each.value.domain_name
//  spring_cloud_app_id = azurerm_spring_cloud_app.app[each.value.spring_cloud_app_name].id
//}

resource "azurerm_spring_cloud_app" "app" {
  for_each = { for app_name in var.azurerm_spring_cloud_apps : app_name.app_name => app_name }

  name                = each.value.app_name
  resource_group_name = var.resource_group_name
  service_name        = azurerm_spring_cloud_service.spring.name

  identity {
    type = each.value.identity_type
  }
}

resource "azurerm_spring_cloud_java_deployment" "deployment" {
  for_each = { for deployment_name in var.azurerm_spring_cloud_java_deployments : deployment_name.deployment_name => deployment_name }
  name                = each.value.deployment_name
  spring_cloud_app_id = azurerm_spring_cloud_app.app[each.value.spring_cloud_app_name].id
  cpu                 = each.value.cpu
  memory_in_gb        = each.value.memory_in_gb
  instance_count      = each.value.instance_count
  jvm_options         = each.value.jvm_options
  runtime_version     = each.value.runtime_version

  environment_variables = {
    "Env" : "Eng"
  }
}

resource "azurerm_spring_cloud_active_deployment" "example" {
  for_each = { for spring_cloud_app_name in var.azurerm_spring_cloud_active_deployments : spring_cloud_app_name.spring_cloud_app_name => spring_cloud_app_name }
  spring_cloud_app_id = azurerm_spring_cloud_app.app[each.value.spring_cloud_app_name].id
  deployment_name     = each.value.deployment_name
}

