# =============================================================================
# Storage Account - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); https_traffic_only, min_tls_version, network_rules (optional)
# Naming: no hyphens (Azure limit). Security: HTTPS only, TLS 1.2, soft delete.
# =============================================================================

variable "storage_accounts" {
  description = "Map of storage account configurations. Keys are logical names."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string

    # Optional - SKU & replication
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    account_kind             = optional(string, "StorageV2")
    access_tier              = optional(string, "Hot")

    # Optional - Security baseline (default: Entra ID / RBAC; set shared_access_key_enabled = true if key-based access is required)
    enable_https_traffic_only       = optional(bool, true)
    min_tls_version                 = optional(string, "TLS1_2")
    allow_nested_items_to_be_public = optional(bool, false)
    public_network_access_enabled   = optional(bool, false)
    shared_access_key_enabled       = optional(bool, false) # false = Entra ID (RBAC) only; true = allow shared key as well

    # Optional - Network rules (when public_network_access_enabled = false, use PE)
    network_rules = optional(object({
      default_action             = optional(string, "Deny")
      bypass                     = optional(list(string), ["AzureServices"])
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
      private_link_access = optional(list(object({
        endpoint_resource_id = string
        endpoint_tenant_id   = optional(string)
      })), [])
    }), null)

    # Optional - Blob properties
    blob_soft_delete_retention_days  = optional(number, 7)
    container_soft_delete_retention_days = optional(number, 7)
    enable_blob_versioning          = optional(bool, false)
    last_access_time_enabled        = optional(bool, false)

    # Optional - Containers
    containers = optional(map(object({
      name          = string
      access_type   = optional(string, "private") # private, blob, container
      metadata      = optional(map(string), {})
    })), {})

    # Optional - Customer-managed key (CMK) encryption; key must exist in Key Vault; storage identity needs key access (Get, Wrap, Unwrap)
    customer_managed_key = optional(object({
      key_vault_id              = string  # Key Vault resource ID e.g. /subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/<name>
      key_name                  = string  # name of the key in the vault
      key_version               = optional(string) # optional; omit for latest/auto-rotation
      user_assigned_identity_id = optional(string) # optional; if null, storage uses system-assigned identity
    }), null)

    # Optional - Lock
    create_delete_lock = optional(bool, false)
    lock_level         = optional(string, "CanNotDelete")

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each storage account's tags."
  type        = map(string)
  default     = {}
}
