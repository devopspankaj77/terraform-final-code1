output "ids" {
  value = { for k, v in azurerm_recovery_services_vault.vault : k => v.id }
}
