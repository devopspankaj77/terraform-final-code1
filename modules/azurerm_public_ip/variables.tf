# =============================================================================
# Public IP - Enterprise Module Variables
# Spec: pip_name, resource_group_name, location, allocation_method (required)
# =============================================================================

variable "public_ips" {
  description = "Map of Public IP configurations. Keys are logical names."
  type = map(object({
    name                = string # Required. Name of the public IP (pip_name in spec).
    resource_group_name = string # Required. Name of the resource group.
    location            = string # Required. Azure region.
    allocation_method   = string # Required. Static or Dynamic. Use Static for production.

    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    zones                   = optional(list(string), [])
    ip_version              = optional(string, "IPv4")
    domain_name_label       = optional(string)
    domain_name_label_scope = optional(string)
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string)
    edge_zone               = optional(string)
    idle_timeout_in_minutes = optional(number, 4)
    ip_tags                 = optional(map(string), {})
    public_ip_prefix_id     = optional(string)
    reverse_fqdn            = optional(string)
    tags                    = optional(map(string), {})
  }))
}
