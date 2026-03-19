# =============================================================================
# User-Assigned Managed Identity - Enterprise Module Variables
# Spec: name, resource_group_name, location (required)
# =============================================================================

variable "identities" {
  description = "Map of user-assigned managed identity configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
