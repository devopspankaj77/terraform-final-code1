# =============================================================================
# NAT Gateway - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); idle_timeout, zones (optional)
# =============================================================================

variable "nat_gateways" {
  description = "Map of NAT Gateway configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    idle_timeout_in_minutes = optional(number, 4)
    sku_name                = optional(string, "Standard")
    zones                   = optional(list(string), [])

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
