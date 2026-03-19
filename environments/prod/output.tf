# =============================================================================
# Prod Environment - Root Outputs
# Aggregates outputs from all child modules for reference and downstream use.
# =============================================================================

# -----------------------------------------------------------------------------
# Resource groups
# -----------------------------------------------------------------------------
output "resource_group_ids" {
  description = "Map of resource group IDs (key = logical name)."
  value       = try(merge([for k, v in module.resource_group : v.ids]...), {})
}

output "resource_group_names" {
  description = "Map of resource group names."
  value       = try(merge([for k, v in module.resource_group : v.names]...), {})
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
output "vnet_ids" {
  description = "Map of virtual network IDs (key = vnet logical name)."
  value       = try(merge([for k, v in module.vnet : v.vnet_ids]...), {})
}

output "vnet_names" {
  description = "Map of virtual network names."
  value       = try(merge([for k, v in module.vnet : v.vnet_names]...), {})
}

output "subnet_ids" {
  description = "Map of subnet IDs (key = vnet_key-subnet_key)."
  value       = try(merge([for k, v in module.vnet : v.subnet_ids]...), {})
}

output "pe_subnet_ids" {
  description = "Map of private endpoint subnet IDs per vnet."
  value       = try(merge([for k, v in module.vnet : v.pe_subnet_ids]...), {})
}

output "public_ip_addresses" {
  description = "Map of public IP addresses (key = pip logical name)."
  value       = try(merge([for k, v in module.public_ip : v.public_ip_addresses]...), {})
}

# -----------------------------------------------------------------------------
# Compute - VMs
# -----------------------------------------------------------------------------
output "linux_vm_ids" {
  description = "Map of Linux VM resource IDs."
  value       = try(merge([for k, v in module.vm : v.vm_ids]...), {})
}

output "linux_vm_private_ips" {
  description = "Map of Linux VM private IP addresses."
  value       = try(merge([for k, v in module.vm : v.vm_private_ips]...), {})
}

output "windows_vm_ids" {
  description = "Map of Windows VM resource IDs."
  value       = try(merge([for k, v in module.vm_windows : v.vm_ids]...), {})
}

output "windows_vm_private_ips" {
  description = "Map of Windows VM private IP addresses."
  value       = try(merge([for k, v in module.vm_windows : v.vm_private_ips]...), {})
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------
output "storage_account_ids" {
  description = "Map of storage account IDs."
  value       = try(merge([for k, v in module.storage_account : v.ids]...), {})
}

output "storage_account_names" {
  description = "Map of storage account names."
  value       = try(merge([for k, v in module.storage_account : v.names]...), {})
}

output "storage_primary_blob_endpoints" {
  description = "Map of storage account primary blob endpoints."
  value       = try(merge([for k, v in module.storage_account : v.primary_blob_endpoints]...), {})
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
output "key_vault_ids" {
  description = "Map of Key Vault IDs."
  value       = try(merge([for k, v in module.keyvault : v.ids]...), {})
}

output "key_vault_uris" {
  description = "Map of Key Vault URIs."
  value       = try(merge([for k, v in module.keyvault : v.vault_uris]...), {})
}

output "key_vault_names" {
  description = "Map of Key Vault names."
  value       = try(merge([for k, v in module.keyvault : v.names]...), {})
}

# -----------------------------------------------------------------------------
# SQL
# -----------------------------------------------------------------------------
output "sql_server_ids" {
  description = "Map of SQL Server IDs."
  value       = try(merge([for k, v in module.sql : v.server_ids]...), {})
}

output "sql_server_fqdns" {
  description = "Map of SQL Server FQDNs."
  value       = try(merge([for k, v in module.sql : v.server_fqdns]...), {})
}

output "sql_database_ids" {
  description = "Map of SQL Database IDs."
  value       = try(merge([for k, v in module.sql : v.database_ids]...), {})
}

# -----------------------------------------------------------------------------
# Private DNS zones
# -----------------------------------------------------------------------------
output "private_dns_zone_ids" {
  description = "Map of Private DNS Zone IDs."
  value       = try(merge([for k, v in module.private_dns_zone : v.zone_ids]...), {})
}

output "private_dns_zone_names" {
  description = "Map of Private DNS Zone names."
  value       = try(merge([for k, v in module.private_dns_zone : v.zone_names]...), {})
}

# -----------------------------------------------------------------------------
# Private endpoints
# -----------------------------------------------------------------------------
output "private_endpoint_ids" {
  description = "Map of private endpoint IDs."
  value       = try(merge([for k, v in module.private_endpoint : v.ids]...), {})
}

output "private_endpoint_private_ips" {
  description = "Map of private endpoint private IP addresses."
  value       = try(merge([for k, v in module.private_endpoint : v.private_ip_addresses]...), {})
}

# -----------------------------------------------------------------------------
# Bastion
# -----------------------------------------------------------------------------
output "bastion_ids" {
  description = "Map of Bastion host IDs."
  value       = try(merge([for k, v in module.bastion : v.ids]...), {})
}

output "bastion_dns_names" {
  description = "Map of Bastion host DNS names."
  value       = try(merge([for k, v in module.bastion : v.dns_names]...), {})
}

# -----------------------------------------------------------------------------
# Container Registry
# -----------------------------------------------------------------------------
output "registry_ids" {
  description = "Map of container registry IDs."
  value       = try(merge([for k, v in module.registry : v.ids]...), {})
}

output "registry_login_servers" {
  description = "Map of container registry login servers."
  value       = try(merge([for k, v in module.registry : v.login_servers]...), {})
}

# -----------------------------------------------------------------------------
# MySQL Flexible
# -----------------------------------------------------------------------------
output "mysql_server_ids" {
  description = "Map of MySQL Flexible Server IDs."
  value       = try(merge([for k, v in module.mysql_flexible : v.ids]...), {})
}

output "mysql_server_fqdns" {
  description = "Map of MySQL Flexible Server FQDNs."
  value       = try(merge([for k, v in module.mysql_flexible : v.fqdns]...), {})
}

# -----------------------------------------------------------------------------
# Redis
# -----------------------------------------------------------------------------
output "redis_cache_ids" {
  description = "Map of Redis cache IDs."
  value       = try(merge([for k, v in module.redis : v.ids]...), {})
}

output "redis_cache_hostnames" {
  description = "Map of Redis cache hostnames."
  value       = try(merge([for k, v in module.redis : v.hostnames]...), {})
}

# -----------------------------------------------------------------------------
# Log Analytics & Application Insights
# -----------------------------------------------------------------------------
output "log_analytics_workspace_ids" {
  description = "Map of Log Analytics workspace IDs."
  value       = try(merge([for k, v in module.log_analytics : v.ids]...), {})
}

output "application_insights_ids" {
  description = "Map of Application Insights resource IDs."
  value       = try(merge([for k, v in module.application_insights : v.ids]...), {})
}

# -----------------------------------------------------------------------------
# App Service (plans + web apps)
# -----------------------------------------------------------------------------
output "app_service_plan_ids" {
  description = "Map of App Service Plan IDs."
  value       = try(length(module.app_service) > 0 ? module.app_service["default"].plan_ids : {}, {})
}

output "linux_web_app_ids" {
  description = "Map of Linux Web App IDs."
  value       = try(length(module.app_service) > 0 ? module.app_service["default"].linux_web_app_ids : {}, {})
}

output "windows_web_app_ids" {
  description = "Map of Windows Web App IDs."
  value       = try(length(module.app_service) > 0 ? module.app_service["default"].windows_web_app_ids : {}, {})
}

# -----------------------------------------------------------------------------
# Function Apps & Logic Apps
# -----------------------------------------------------------------------------
output "function_app_ids" {
  description = "Map of Function App IDs (Linux and Windows combined where present)."
  value       = try(merge(
    merge([for k, v in module.function_app : try(v.linux_function_app_ids, {})]...),
    merge([for k, v in module.function_app : try(v.windows_function_app_ids, {})]...)
  ), {})
}

output "logic_app_ids" {
  description = "Map of Logic App (Standard) IDs."
  value       = try(merge([for k, v in module.logic_app : v.ids]...), {})
}

# -----------------------------------------------------------------------------
# API Management
# -----------------------------------------------------------------------------
output "api_management_ids" {
  description = "Map of API Management service IDs."
  value       = try(merge([for k, v in module.api_management : v.ids]...), {})
}

output "api_management_gateway_urls" {
  description = "Map of API Management gateway URLs."
  value       = try(merge([for k, v in module.api_management : v.gateway_urls]...), {})
}

# -----------------------------------------------------------------------------
# AKS
# -----------------------------------------------------------------------------
output "aks_cluster_ids" {
  description = "Map of AKS cluster IDs."
  value       = try(merge([for k, v in module.aks : v.ids]...), {})
}

# -----------------------------------------------------------------------------
# Recovery Services Vault
# -----------------------------------------------------------------------------
output "recovery_services_vault_ids" {
  description = "Map of Recovery Services Vault IDs."
  value       = try(merge([for k, v in module.recovery_services_vault : v.ids]...), {})
}

# -----------------------------------------------------------------------------
# User-assigned managed identities
# -----------------------------------------------------------------------------
output "user_assigned_identity_ids" {
  description = "Map of user-assigned managed identity IDs."
  value       = try(merge([for k, v in module.user_assigned_identity : v.ids]...), {})
}

output "user_assigned_identity_principal_ids" {
  description = "Map of user-assigned managed identity principal IDs."
  value       = try(merge([for k, v in module.user_assigned_identity : v.principal_ids]...), {})
}

# -----------------------------------------------------------------------------
# Environment summary
# -----------------------------------------------------------------------------
output "environment" {
  description = "Environment name (from tfvars)."
  value       = var.environment
}

output "location" {
  description = "Primary Azure region for this environment."
  value       = var.location
}
