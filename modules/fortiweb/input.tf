variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "fortiweb_front_subnet_id" {
  type = string
}

variable "fortiweb_vm_name" {
  type = string
}

variable "fortiweb_username" {
  type = string
}

variable "fortiweb_pw" {
  type = string
}

# variable "fortiweb_back_subnet_id" {
#   type = string
# }

variable "fortiweb_nsg_rules" {

}

variable "fortiweb_disk_size" {
  type = string
  default = "128"
}
