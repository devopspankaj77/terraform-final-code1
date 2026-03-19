# =============================================================================
# API Management - Enterprise Module Variables
# Spec: name, resource_group_name, location, publisher_*, sku_name (required)
# =============================================================================

variable "api_managements" {
  description = "Map of API Management service configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    publisher_name      = string
    publisher_email     = string
    sku_name            = string # Developer_1, Consumption, Basic, Standard_1, Standard_2, Premium_1

    subnet_id            = optional(string)
    public_network_access_enabled = optional(bool, true)
    identity_type        = optional(string, "SystemAssigned")
    identity_ids         = optional(list(string), [])

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
