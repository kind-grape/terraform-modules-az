

resource "azurerm_application_gateway" "network" {
  name                = "DevWAF"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.apim_subnet
  }

  frontend_port {
    name = var.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                  = var.frontend_ip_configuration_name
    private_ip_address    = var.private_ip_address
    subnet_id             = var.apim_subnet
  }

  backend_address_pool {
    name = var.backend_address_pool_name
    ip_addresses = var.backend_ip_addresses
  }

  //authentication_certificate {
  //    name = "apigee-dev51cb1c50-dd32-4ce8-8519-fe1d6ec1f16a"
  //    data = "filesomewhere"  
  //}


  backend_http_settings {
    name                  = var.http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    affinity_cookie_name                = "ApplicationGatewayAffinity"

    pick_host_name_from_backend_address =true
    //authentication_certificate {
    //  name = "apigee-dev51cb1c50-dd32-4ce8-8519-fe1d6ec1f16a"
    //}

    probe_name = var.probe_name
  }

  probe {
    interval = 5
    name = var.probe_name
    protocol = "Https"
    path ="/"
    timeout = 30
    unhealthy_threshold = 10
    pick_host_name_from_backend_http_settings = true
  }

  dynamic "ssl_certificate" {
    iterator = pub
    for_each = var.ssl_certificates
    content {
      name                           = pub.value.name
    }
  }

  dynamic "http_listener" {
    iterator = pub
    for_each = var.http_listeners
    content {
      name                           = pub.value.listener_name
      host_name = pub.value.host_name
      require_sni = pub.value.require_sni
      frontend_ip_configuration_name = pub.value.frontend_ip_configuration_name
      frontend_port_name             = var.frontend_port_name
      protocol                       = pub.value.protocol
      ssl_certificate_name             = pub.value.ssl_certificate_name //azurerm_application_gateway.network.ssl_certificate.id
    }
  }

  dynamic "request_routing_rule" {
    iterator = pub
    for_each = var.request_routing_rules
    content {
      name                       = pub.value.request_routing_rule_name
      rule_type                  = pub.value.rule_type
      http_listener_name         = pub.value.http_listener_name
      backend_address_pool_name  = var.backend_address_pool_name
      backend_http_settings_name = var.http_settings_name
    }
  }

  waf_configuration {
    enabled = var.waf_enabled
    firewall_mode = var.waf_firewall_mode
    rule_set_type =var.waf_rule_set_type
    rule_set_version = var.waf_rule_set_version
    file_upload_limit_mb =var.waf_file_upload_limit_mb
    request_body_check = var.waf_request_body_check
    max_request_body_size_kb = var.waf_max_request_body_size_kb
  }
}