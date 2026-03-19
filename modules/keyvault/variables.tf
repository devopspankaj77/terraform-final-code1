# =============================================================================
# Key Vault - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); enable_rbac_authorization, soft_delete, purge_protection (optional)
# Naming: max 24 chars. Security: RBAC only, soft delete, purge protection.
# =============================================================================

variable "key_vaults" {
  description = "Map of Key Vault configurations. Keys are logical names."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string

    # Optional - SKU
    sku_name = optional(string, "standard")

    # Optional - Security baseline
    enabled_for_disk_encryption   = optional(bool, false)
    enabled_for_deployment        = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    enable_rbac_authorization     = optional(bool, true)
    soft_delete_retention_days    = optional(number, 90)
    purge_protection_enabled     = optional(bool, true)
    public_network_access_enabled = optional(bool, false)

    # Optional - Network (when public_network_access_enabled = false use PE)
    network_acls = optional(object({
      default_action = optional(string, "Deny")
      bypass         = optional(string, "AzureServices")
      ip_rules       = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), { default_action = "Deny", bypass = "AzureServices" })

    # Optional - Lock
    create_delete_lock = optional(bool, false)
    lock_level         = optional(string, "CanNotDelete")

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each Key Vault's tags."
  type        = map(string)
  default     = {}
}
