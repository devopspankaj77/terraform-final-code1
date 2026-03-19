output "ids" {
  description = "Map of private endpoint IDs."
  value       = { for k, v in azurerm_private_endpoint.pe : k => v.id }
}

output "private_ip_addresses" {
  description = "Map of private endpoint NIC private IPs."
  value       = { for k, v in azurerm_private_endpoint.pe : k => v.private_service_connection[0].private_ip_address }
}
