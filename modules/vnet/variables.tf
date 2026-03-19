# =============================================================================
# Virtual Network - Enterprise Module Variables
# Spec: vnet_name, resource_group_name, location, address_space (required); dns_servers, subnets (optional)
# Naming: ICR-<nnn>-Azure-<INT|CLT>-VNet-<Workload>
# =============================================================================

variable "vnets" {
  description = "Map of virtual network configurations. Keys are logical names."
  type = map(object({
    name                = string        # Required. Virtual network name.
    resource_group_name = string        # Required. Name of the resource group.
    location            = string        # Required. Azure region.
    address_space       = list(string)  # Required. Address space(s), e.g. ["10.0.0.0/16"].

    tags        = optional(map(string), {})
    dns_servers = optional(list(string), [])

    # Optional - Subnets (each subnet can have its own nsg_rules for least-privilege; else vnet-level nsg_rules apply)
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
      allow_private_endpoint = optional(bool, false)
      service_endpoints      = optional(list(string), [])
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      }), null)
      # Optional - NSG rules for this subnet only (recommended: define per subnet for clarity and security)
      nsg_rules = optional(map(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = optional(string, "*")
        source_port_range          = optional(string, "*")
        destination_port_range     = optional(string)
        source_address_prefix      = optional(string)
        destination_address_prefix = optional(string, "*")
        source_address_prefixes    = optional(list(string), [])
        destination_address_prefixes = optional(list(string), [])
        description                = optional(string)
      })), {})
    })), {})

    # Optional - Create NSG per subnet or single NSG for VNet
    create_nsg            = optional(bool, true)
    nsg_per_subnet        = optional(bool, true)
    nsg_rules = optional(map(object({
      name                       = string
      priority                   = number
      direction                  = string # Inbound, Outbound
      access                     = string # Allow, Deny
      protocol                   = optional(string, "*")
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string, "*")
      source_address_prefixes    = optional(list(string), [])
      destination_address_prefixes = optional(list(string), [])
      description                = optional(string)
    })), {})

    # Optional - Create dedicated subnet for private endpoints (policies disabled)
    create_private_endpoint_subnet = optional(bool, false)
    private_endpoint_subnet_prefix = optional(string, "10.0.254.0/24")
    # Optional - NSG rules for PE subnet when nsg_per_subnet is true (same structure as nsg_rules)
    pe_subnet_nsg_rules = optional(map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = optional(string, "*")
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string, "*")
      source_address_prefixes    = optional(list(string), [])
      destination_address_prefixes = optional(list(string), [])
      description                = optional(string)
    })), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each resource's tags."
  type        = map(string)
  default     = {}
}
