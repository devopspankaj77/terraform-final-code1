# =============================================================================
# Function App - Enterprise Module Variables
# Spec: name, resource_group_name, location, storage_account_id, app_service_plan_id (required)
# =============================================================================

variable "function_apps" {
  description = "Map of Function App configurations. Keys are logical names."
  type = map(object({
    name                       = string
    resource_group_name        = string
    location                   = string
    storage_account_name       = string
    storage_account_access_key = optional(string, null) # null = use Entra ID (managed identity); set when shared key enabled
    app_service_plan_id        = string

    # When storage_account_access_key is null, set use_storage_identity = true and storage_account_id for RBAC
    use_storage_identity = optional(bool, false)
    storage_account_id   = optional(string, null)
    # Set to false when Terraform runner lacks User Access Administrator (roleAssignments/write); assign storage roles manually in Portal
    create_storage_rbac  = optional(bool, true)

    os_type                = optional(string, "Linux")
    version                = optional(string, "~4")
    node_version           = optional(string, "18") # One of: "12", "14", "16", "18", "20", "22"
    https_only             = optional(bool, true)
    ftps_state             = optional(string, "Disabled")
    minimum_tls_version     = optional(string, "1.2")

    app_settings = optional(map(string), {})
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
