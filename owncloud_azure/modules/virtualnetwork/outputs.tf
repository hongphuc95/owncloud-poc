output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource group name"
}

output "nic_id" {
  value       = azurerm_network_interface.nic.id
  description = "Network interface id"
}

