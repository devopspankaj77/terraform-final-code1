# =============================================================================
# Private DNS Zone - Enterprise Module Variables
# Spec: name, resource_group_name (required); vnet_links (optional) for PE resolution
# =============================================================================

variable "private_dns_zones" {
  description = "Map of Private DNS Zone configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string

    # VNet links: use vnet_key (resolved via var.vnet_ids from root) or vnet_id directly
    vnet_links = optional(map(object({
      vnet_id             = optional(string) # set by root when resolving; or pass directly
      vnet_key            = optional(string) # logical key; root passes vnet_ids map
      registration_enabled = optional(bool, false)
    })), {})

    tags = optional(map(string), {})
  }))
}

variable "vnet_ids" {
  description = "Map of vnet_key -> vnet_id from root (module.vnet). Used when vnet_links use vnet_key."
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags merged with each zone's tags."
  type        = map(string)
  default     = {}
}
