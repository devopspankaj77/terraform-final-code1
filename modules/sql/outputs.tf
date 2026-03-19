output "server_ids" {
  description = "Map of SQL Server IDs."
  value       = { for k, v in azurerm_mssql_server.server : k => v.id }
}

output "server_fqdns" {
  description = "Map of SQL Server FQDNs."
  value       = { for k, v in azurerm_mssql_server.server : k => v.fully_qualified_domain_name }
}

output "database_ids" {
  description = "Map of SQL Database IDs (key = server_key-db_key)."
  value       = { for k, v in azurerm_mssql_database.db : k => v.id }
}
