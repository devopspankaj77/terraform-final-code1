output "ids" {
  description = "Map of storage account IDs."
  value       = { for k, v in azurerm_storage_account.sa : k => v.id }
}

output "names" {
  description = "Map of storage account names."
  value       = { for k, v in azurerm_storage_account.sa : k => v.name }
}

output "primary_blob_endpoints" {
  description = "Map of primary blob endpoints (for private endpoint DNS)."
  value       = { for k, v in azurerm_storage_account.sa : k => v.primary_blob_endpoint }
}

output "primary_connection_strings" {
  description = "Map of primary connection strings (sensitive)."
  value       = { for k, v in azurerm_storage_account.sa : k => v.primary_connection_string }
  sensitive   = true
}

output "primary_access_keys" {
  description = "Map of primary storage account access keys (sensitive)."
  value       = { for k, v in azurerm_storage_account.sa : k => v.primary_access_key }
  sensitive   = true
}
