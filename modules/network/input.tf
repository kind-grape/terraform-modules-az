# variables declarations that are passed in to the component module go here
# supply the actual values in terraform.tfvars within the environment folder

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "lb_sku" {
  type = string
}

#variable "lb_frontend_ip_config_name" {
#    type = string
#}

variable "lb_frontend_ip_config_subnet_id" {

}

#variable "lb_frontend_ip_config_private_ip_address" {
#    type = string
#}

variable "lb_tags" {
    type = map 
}

variable "lb_frontend_configs" {

}

variable "lb_probes" {

}

variable "lb_backend_pools" {

}

variable "lb_rules" {

}




