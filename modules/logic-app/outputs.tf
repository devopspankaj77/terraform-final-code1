output "ids" {
  value = { for k, v in azurerm_logic_app_standard.logic_app : k => v.id }
}
