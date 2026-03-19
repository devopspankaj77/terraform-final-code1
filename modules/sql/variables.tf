# =============================================================================
# Azure SQL Server & Database - Enterprise Module Variables
# Prefer Entra ID (azuread_administrator + azuread_authentication_only = true); admin login/password optional.
# =============================================================================

variable "sql_servers" {
  description = "Map of SQL Server configurations; each can contain databases. Keys are logical names."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string
    version             = optional(string, "12.0")

    # Optional - SQL auth (omit when using Entra ID only; set azuread_administrator.azuread_authentication_only = true)
    administrator_login          = optional(string, null)
    administrator_login_password = optional(string, null) # sensitive; use TF_VAR or KV when SQL auth enabled

    # Optional - Security
    minimum_tls_version          = optional(string, "1.2")
    public_network_access_enabled = optional(bool, false)

    # Optional - Entra ID (preferred); set azuread_authentication_only = true for Entra-only (no SQL login)
    azuread_administrator = optional(object({
      login_username              = string
      object_id                   = string
      tenant_id                   = optional(string)
      azuread_authentication_only = optional(bool, false) # true = Entra ID only; SQL login/password not used
    }), null)

    # Optional - Firewall (restrict to VNet/subnet; avoid 0.0.0.0/0 in prod)
    firewall_rules = optional(map(object({
      name             = string
      start_ip_address = string
      end_ip_address   = string
    })), {})

    # Optional - Databases
    databases = optional(map(object({
      name         = string
      collation    = optional(string, "SQL_Latin1_General_CP1_CI_AS")
      license_type = optional(string, "LicenseIncluded")
      max_size_gb  = optional(number, 2)
      sku_name     = optional(string, "S0")
      short_term_retention_days = optional(number, 7)
      long_term_retention_policy = optional(object({
        weekly_retention  = optional(string)
        monthly_retention = optional(string)
        yearly_retention  = optional(string)
        week_of_year     = optional(number)
      }), null)
      tags = optional(map(string), {})
    })), {})

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each resource's tags."
  type        = map(string)
  default     = {}
}
