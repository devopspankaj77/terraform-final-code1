output "linux_function_app_ids" {
  value = { for k, v in azurerm_linux_function_app.func_linux : k => v.id }
}
output "windows_function_app_ids" {
  value = { for k, v in azurerm_windows_function_app.func_windows : k => v.id }
}
