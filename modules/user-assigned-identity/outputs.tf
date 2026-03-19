output "ids" {
  value = { for k, v in azurerm_user_assigned_identity.identity : k => v.id }
}
output "principal_ids" {
  value = { for k, v in azurerm_user_assigned_identity.identity : k => v.principal_id }
}
output "client_ids" {
  value = { for k, v in azurerm_user_assigned_identity.identity : k => v.client_id }
}
