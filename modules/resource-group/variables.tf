# =============================================================================
# Resource Group - Enterprise Module Variables
# Spec: resource_group_name, location (required); tags, managed_by, lock (optional)
# Naming: ICR-<nnn>-Azure-<INT|CLT>-RG-<Workload>
# =============================================================================

variable "resource_groups" {
  description = "Map of resource group configurations. Keys are logical names."
  type = map(object({
    name     = string # Required. Name of the resource group.
    location = string # Required. Azure region to create the resource group (e.g. eastus, centralindia).

    tags       = optional(map(string), {})   # Optional. Tags to apply; merged with common_tags.
    managed_by = optional(string)            # Optional. ID of the resource that manages this RG.

    create_lock = optional(bool, false)                    # Optional. If true, apply a delete lock. Default false.
    lock_level  = optional(string, "CanNotDelete")          # Optional. CanNotDelete or ReadOnly.
    lock_name   = optional(string)                          # Optional. Lock name; defaults to ${key}-lock.
  }))
}

variable "common_tags" {
  description = "Common tags merged with each resource's tags (e.g. company-mandatory)."
  type        = map(string)
  default     = {}
}
