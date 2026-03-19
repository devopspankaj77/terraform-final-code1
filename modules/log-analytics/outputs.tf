output "ids" {
  value = { for k, v in azurerm_log_analytics_workspace.workspace : k => v.id }
}
output "workspace_ids" {
  value = { for k, v in azurerm_log_analytics_workspace.workspace : k => v.id }
}
output "workspace_keys" {
  value     = { for k, v in azurerm_log_analytics_workspace.workspace : k => v.primary_shared_key }
  sensitive = true
}
