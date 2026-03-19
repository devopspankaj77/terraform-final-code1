output "ids" {
  description = "Map of ACR IDs."
  value       = { for k, v in azurerm_container_registry.acr : k => v.id }
}

output "login_servers" {
  description = "Map of ACR login server FQDNs."
  value       = { for k, v in azurerm_container_registry.acr : k => v.login_server }
}

output "names" {
  description = "Map of ACR names."
  value       = { for k, v in azurerm_container_registry.acr : k => v.name }
}
