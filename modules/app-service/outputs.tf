output "plan_ids" {
  value = { for k, v in azurerm_service_plan.plan : k => v.id }
}
output "linux_web_app_ids" {
  value = { for k, v in azurerm_linux_web_app.app_linux : k => v.id }
}
output "windows_web_app_ids" {
  value = { for k, v in azurerm_windows_web_app.app_windows : k => v.id }
}
