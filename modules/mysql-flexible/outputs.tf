output "ids" {
  value = { for k, v in azurerm_mysql_flexible_server.mysql : k => v.id }
}
output "fqdns" {
  value = { for k, v in azurerm_mysql_flexible_server.mysql : k => v.fqdn }
}
