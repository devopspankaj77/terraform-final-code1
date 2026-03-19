# =============================================================================
# Bastion Host - Enterprise Module Variables
# Spec: name, resource_group_name, location, subnet_id, public_ip_id (required)
# =============================================================================

variable "bastion_hosts" {
  description = "Map of Bastion host configurations. Keys are logical names."
  type = map(object({
    name                = string # Required.
    resource_group_name = string
    location            = string
    subnet_id           = string # Must be dedicated Bastion subnet (min /26).
    public_ip_id       = string # Required. Standard SKU public IP for Bastion.

    sku                     = optional(string, "Standard") # Basic | Standard; ip_connect_enabled only supported for Standard
    copy_paste_enabled     = optional(bool, true)
    file_copy_enabled      = optional(bool, false)
    ip_connect_enabled     = optional(bool, true) # Only applied when sku is Standard (or Premium)
    scale_units            = optional(number, 2)
    shareable_link_enabled = optional(bool, false)
    tunneling_enabled      = optional(bool, false)

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}
