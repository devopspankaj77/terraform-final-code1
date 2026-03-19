# =============================================================================
# Azure Database for MySQL Flexible Server - Enterprise Module Variables
# Prefer Entra ID; administrator_login and administrator_password optional (set when using MySQL auth).
# =============================================================================

variable "mysql_servers" {
  description = "Map of MySQL Flexible Server configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    # Optional - omit for Entra ID–only; set when using MySQL native auth
    administrator_login    = optional(string, null)
    administrator_password = optional(string, null) # sensitive; use TF_VAR or KV when MySQL auth enabled

    sku_name   = optional(string, "GP_Standard_D2ds_v4")
    version    = optional(string, "8.0.21")
    storage_gb = optional(number, 20)
    zone       = optional(string)

    backup_retention_days        = optional(number, 7)
    geo_redundant_backup_enabled = optional(bool, false)

    public_network_access_enabled = optional(bool, false)
    delegated_subnet_id           = optional(string)
    private_dns_zone_id           = optional(string)

    firewall_rules = optional(map(object({
      name             = string
      start_ip_address = string
      end_ip_address   = string
    })), {})

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
