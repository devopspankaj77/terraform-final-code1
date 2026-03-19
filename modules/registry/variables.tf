# =============================================================================
# Azure Container Registry - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); admin_enabled=false, public_network_access (optional)
# Naming: no hyphens. Security: admin_enabled=false when using PE.
# =============================================================================

variable "registries" {
  description = "Map of container registry configurations. Keys are logical names."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Standard") # Basic, Standard, Premium

    # Optional - Security baseline
    admin_enabled                  = optional(bool, false)
    public_network_access_enabled  = optional(bool, true) # set false when using PE
    quarantine_policy_enabled      = optional(bool, false)
    anonymous_pull_enabled         = optional(bool, false)
    data_endpoint_enabled          = optional(bool, false)

    # Optional - Retention
    retention_policy = optional(object({
      days    = optional(number, 7)
      enabled = optional(bool, false)
    }), null)
    trust_policy = optional(object({
      enabled = optional(bool, false)
    }), null)

    # Optional - Encryption (Premium)
    encryption = optional(object({
      enabled  = optional(bool, false)
      key_vault_key_id = optional(string)
      identity_client_id = optional(string)
    }), null)

    # Optional - Network (Premium; single block)
    network_rule_bypass_option = optional(string, "AzureServices")
    network_rule_set = optional(object({
      default_action = optional(string, "Deny")
      ip_rule = optional(list(object({
        action   = string
        ip_range = string
      })), [])
      virtual_network = optional(list(object({
        action    = string
        subnet_id = string
      })), [])
    }), null)

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each registry's tags."
  type        = map(string)
  default     = {}
}
