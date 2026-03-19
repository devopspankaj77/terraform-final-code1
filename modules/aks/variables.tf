# =============================================================================
# AKS - Enterprise Module Variables
# Spec: name, resource_group_name, location, dns_prefix, default_node_pool (required)
# Security: enable_azure_rbac, network_policy (optional)
# =============================================================================

variable "aks_clusters" {
  description = "Map of AKS cluster configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    dns_prefix          = string

    default_node_pool = object({
      name                = string
      vm_size             = string
      node_count         = optional(number, 1)
      enable_auto_scaling = optional(bool, false)
      min_count          = optional(number)
      max_count          = optional(number)
      vnet_subnet_id     = optional(string)
    })

    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])

    enable_azure_rbac     = optional(bool, true)
    admin_group_object_ids = optional(list(string), [])
    # service_cidr and dns_service_ip must not overlap with VNet/subnet CIDRs (e.g. use 172.16.0.0/16 if VNet is 10.0.0.0/16)
    network_profile = optional(object({
      network_plugin     = optional(string, "azure")
      network_policy     = optional(string, "azure")
      load_balancer_sku  = optional(string, "standard")
      service_cidr       = optional(string, "172.16.0.0/16")
      dns_service_ip     = optional(string, "172.16.0.10")
    }), {})

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
