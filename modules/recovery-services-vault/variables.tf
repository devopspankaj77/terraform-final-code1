# =============================================================================
# Recovery Services Vault - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); soft_delete_enabled, create_lock (optional)
# =============================================================================

variable "vaults" {
  description = "Map of Recovery Services Vault configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    sku                 = optional(string, "Standard")
    soft_delete_enabled = optional(bool, true)
    create_lock         = optional(bool, false)
    lock_level          = optional(string, "CanNotDelete")

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
