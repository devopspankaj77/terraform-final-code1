# =============================================================================
# Logic App (Standard) - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); app_service_plan_id, storage_* (optional)
# =============================================================================

variable "logic_apps" {
  description = "Map of Logic App workflow configurations. Keys are logical names."
  type = map(object({
    name                       = string
    resource_group_name        = string
    location                   = string
    app_service_plan_id        = string
    storage_account_name       = string
    storage_account_access_key = optional(string, null) # null = use Entra ID (managed identity)
    use_storage_identity       = optional(bool, false)
    storage_account_id         = optional(string, null)

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
