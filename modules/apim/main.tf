resource "azurerm_api_management" "example" {
  name                = var.apim_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  publisher_name      = var.apim_company_name
  publisher_email     = var.apim_company_email
  
  sku_name             = var.apim_sku_name
  virtual_network_type = var.apim_virtual_network_type
  
  virtual_network_configuration {
      subnet_id = var.apim_subnet
  }
  lifecycle {
    ignore_changes = [tags]
  }

}


//resource "azurerm_api_management" "engtest" {
//    name                = var.apim_name
//  location            = var.resource_group_location
//  resource_group_name = var.resource_group_name
//  publisher_name      = var.apim_company_name
//  publisher_email     = var.apim_company_email
//  
//  sku_name = var.apim_sku_name
//  virtual_network_type = var.apim_virtual_network_type
//  
//  virtual_network_configuration {
//      subnet_id = "/subscriptions/be871b97-1f7a-44b2-8e03-80ba1b1ac7d5/resourceGroups/EsDCAMPRG/providers/Microsoft.Network/virtualNetworks/EsDCAMPVNet/subnets/engapim" //var.apim_subnet
//  }
//
//}

//resource "azurerm_api_management_policy" "example" {
//  api_management_id = azurerm_api_management.example.id
//  xml_content       = file("example.xml")
//}

//resource "azurerm_api_management_group" "example" {
//  name                = "example-apimg"
//  resource_group_name = var.resource_group_name
//  api_management_name = azurerm_api_management.example.name
//  display_name        = "Example Group"
//  description         = "This is an example API management group."
//}

resource "azurerm_application_insights" "example" {
  name                = var.azurerm_application_insights_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  application_type    = var.azurerm_application_insights_application_type
  
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_api_management_logger" "example" {
  name                = "example-apimlogger"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.example.name

  application_insights {
    instrumentation_key = azurerm_application_insights.example.instrumentation_key
  }
}

resource "azurerm_api_management_custom_domain" "example" {
  api_management_id = azurerm_api_management.example.id

  proxy {
    certificate = var.certificate
    certificate_password = var.certificate_password
    host_name    = var.custom_domain_gateway_host_name
  }

  management {
    certificate = var.certificate
    certificate_password = var.certificate_password
    host_name    = var.custom_domain_management_host_name
  }

  developer_portal  {
    certificate = var.certificate
    certificate_password = var.certificate_password
    host_name  = var.custom_domain_developer_portal_host_name
  }

  scm  {
    certificate = var.certificate
    certificate_password = var.certificate_password
    host_name  = var.custom_domain_scm_host_name
  }
}

resource "azurerm_lb_backend_address_pool_address" "apim_backend_address" {
  #for_each = azurerm_api_management.example.private_ip_addresses 
  name                    = var.apim_backend_address_name
  backend_address_pool_id = var.backend_address_pool_id
  virtual_network_id      = var.virtual_network_id
  ip_address              = "10.72.95.157"#each.key
  depends_on = [
    azurerm_api_management.example
  ]
}