variable "project" {
  description = "Name of the project"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "resource_group_location" {
  type        = string
  description = "Region in which Azure Resources to be created"
  default     = "francecentral"
}

// Networking
variable "vnet_address_space" {
  type        = list(any)
  description = "Virtual Network address_space"
}

variable "vm_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the VM subnet"
}