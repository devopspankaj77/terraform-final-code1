# =============================================================================
# Azure SQL Server & Database - Enterprise Module
# Security: minimum TLS 1.2, firewall, Azure AD admin, backup retention
# =============================================================================

resource "azurerm_mssql_server" "server" {
  for_each = var.sql_servers

  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  location                     = each.value.location
  version                      = each.value.version
  administrator_login          = each.value.administrator_login
  administrator_login_password = each.value.administrator_login_password
  minimum_tls_version          = each.value.minimum_tls_version
  public_network_access_enabled = each.value.public_network_access_enabled

  dynamic "azuread_administrator" {
    for_each = each.value.azuread_administrator != null ? [each.value.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = try(azuread_administrator.value.tenant_id, null)
      azuread_authentication_only = try(azuread_administrator.value.azuread_authentication_only, false)
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_mssql_firewall_rule" "rule" {
  for_each = local.sql_firewall_rules

  name             = each.value.name
  server_id        = azurerm_mssql_server.server[each.value.server_key].id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Firewall rules only when public network access is enabled (Azure does not allow firewall rules when public_network_access_enabled = false)
locals {
  sql_firewall_rules = merge([
    for sk, sv in var.sql_servers :
    try(sv.public_network_access_enabled, true) ? { for fk, fv in try(sv.firewall_rules, {}) : "${sk}-${fk}" => merge(fv, { server_key = sk }) } : {}
  ]...)
}

resource "azurerm_mssql_database" "db" {
  for_each = local.sql_databases

  name         = each.value.name
  server_id    = azurerm_mssql_server.server[each.value.server_key].id
  collation    = each.value.collation
  license_type = each.value.license_type
  max_size_gb  = each.value.max_size_gb
  sku_name     = each.value.sku_name

  short_term_retention_policy {
    retention_days = each.value.short_term_retention_days
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_retention_policy != null ? [each.value.long_term_retention_policy] : []
    content {
      weekly_retention  = try(long_term_retention_policy.value.weekly_retention, null)
      monthly_retention = try(long_term_retention_policy.value.monthly_retention, null)
      yearly_retention  = try(long_term_retention_policy.value.yearly_retention, null)
      week_of_year      = try(long_term_retention_policy.value.week_of_year, null)
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}

locals {
  sql_databases = merge([
    for sk, sv in var.sql_servers : {
      for dk, dv in try(sv.databases, {}) : "${sk}-${dk}" => merge(dv, { server_key = sk })
    }
  ]...)
}
