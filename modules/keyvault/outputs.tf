output "ids" {
  description = "Map of Key Vault IDs."
  value       = { for k, v in azurerm_key_vault.kv : k => v.id }
}

output "vault_uris" {
  description = "Map of Key Vault URIs."
  value       = { for k, v in azurerm_key_vault.kv : k => v.vault_uri }
}

output "names" {
  description = "Map of Key Vault names."
  value       = { for k, v in azurerm_key_vault.kv : k => v.name }
}
