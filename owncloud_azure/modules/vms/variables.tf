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

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "nic_id" {
  type        = string
  description = "Network Interface ID"
}

variable "vm_size" {
  type        = string
  description = "Size of VM"
}