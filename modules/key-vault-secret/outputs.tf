output "secret_ids" {
  description = "Map of secret resource IDs."
  value       = { for k, v in azurerm_key_vault_secret.secret : k => v.id }
}

output "secret_versions" {
  description = "Map of secret version IDs (for references)."
  value       = { for k, v in azurerm_key_vault_secret.secret : k => v.version }
}
