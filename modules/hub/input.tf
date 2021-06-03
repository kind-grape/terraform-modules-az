# variables declarations that are passed in to the component module go here
# supply the actual values in terraform.tfvars within the environment folder

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "resource_group_tags" {
    type = map 
}

//variable "vnet_spoke_peered_name" {
//  type = string
//}
//
//variable "vnet_spoke_peered_address_space" {
//  type = string
//}

variable "vnet_spoke_peered_tags" {
    type = map 
}

variable "vnet_spoke_peered_subnets" {

}

variable "vnet_spoke_peered_rt_tables" {
}

variable "vnet_spoke_peered_rt_routes" {

}

//variable "vnet_spoke_peered_nsg_tags" {
//  
//}
//variable "vnet_spoke_peered_nsg_name" {
//  
//}

variable "vnet_spoke_peered_nsg_rules" {
  
}

variable "vnet_dns_servers_ips" {

}

variable "application_security_groups" {

}
variable "spoke_peered_vnets" {

}

variable "spoke_peered_nsgs" {

}
variable "dns_zones" {
  
}
variable "dns_cname_records" {
  
}
variable "dns_a_records" {
  
}
variable "dns_ns_records" {
  
}