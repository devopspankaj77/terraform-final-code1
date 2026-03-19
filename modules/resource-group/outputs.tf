output "ids" {
  description = "Map of resource group IDs."
  value       = { for k, v in azurerm_resource_group.rg : k => v.id }
}

output "names" {
  description = "Map of resource group names."
  value       = { for k, v in azurerm_resource_group.rg : k => v.name }
}

output "locations" {
  description = "Map of resource group locations."
  value       = { for k, v in azurerm_resource_group.rg : k => v.location }
}
