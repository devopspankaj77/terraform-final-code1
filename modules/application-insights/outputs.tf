output "ids" {
  value = { for k, v in azurerm_application_insights.ai : k => v.id }
}
output "instrumentation_keys" {
  value     = { for k, v in azurerm_application_insights.ai : k => v.instrumentation_key }
  sensitive = true
}
output "connection_strings" {
  value     = { for k, v in azurerm_application_insights.ai : k => v.connection_string }
  sensitive = true
}
