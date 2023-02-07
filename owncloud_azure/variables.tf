variable "resource_group_location" {
  type        = string
  description = "Region in which Azure Resources to be created"
  default     = "francecentral"
}

variable "project" {
  description = "Name of the project"
  default     = "owncloud"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vnet_address_space" {
  type        = list(any)
  description = "Virtual Network address_space"
}

variable "vm_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the VM subnet"
}
