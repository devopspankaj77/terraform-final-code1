# =============================================================================
# Log Analytics Workspace - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); retention_in_days, sku (optional)
# =============================================================================

variable "workspaces" {
  description = "Map of Log Analytics workspace configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    sku               = optional(string, "PerGB2018")
    retention_in_days = optional(number, 30)
    daily_quota_gb   = optional(number)

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
