output "zone_ids" {
  description = "Map of Private DNS Zone IDs."
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.id }
}

output "zone_names" {
  description = "Map of Private DNS Zone names."
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.name }
}
