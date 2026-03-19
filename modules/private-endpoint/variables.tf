# =============================================================================
# Private Endpoint - Enterprise Module Variables
# Spec: name, resource_group_name, location, subnet_id, resource_id, subresource_names (required); private_dns_zone_id (optional)
# =============================================================================

variable "private_endpoints" {
  description = "Map of private endpoint configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    subnet_id           = string

    # Target resource
    resource_id = string
    subresource_names = list(string) # e.g. ["blob"], ["vault"], ["sqlServer"]

    # Optional - Private DNS zone (recommended for automatic resolution)
    private_dns_zone_id = optional(string)
    private_dns_zone_group_name = optional(string, "default")

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each private endpoint's tags."
  type        = map(string)
  default     = {}
}
