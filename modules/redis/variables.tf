# =============================================================================
# Azure Cache for Redis - Enterprise Module Variables
# Spec: name, resource_group_name, location, sku_name, family, capacity (required)
# Security: non_ssl_port_enabled=false, minimum_tls_version=1.2
# =============================================================================

variable "redis_caches" {
  description = "Map of Redis cache configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku_name   = string # Basic, Standard, Premium
    family     = string # C, P
    capacity   = number

    enable_non_ssl_port = optional(bool, false)
    minimum_tls_version = optional(string, "1.2")
    public_network_access_enabled = optional(bool, true)

    redis_configuration = optional(map(string), {})
    subnet_id           = optional(string)
    private_static_ip_address = optional(string)

    zones = optional(list(string), [])

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
