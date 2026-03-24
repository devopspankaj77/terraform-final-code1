# =============================================================================
# Role assignment module – Azure RBAC (azurerm_role_assignment)
# =============================================================================

variable "role_assignments" {
  description = "Map of RBAC role assignments. Key = unique name; scope_id = full Azure resource ID for the assignment scope."
  type = map(object({
    scope_id             = string
    role_definition_name = string
    principal_id         = string
    principal_type       = optional(string)
    description          = optional(string)
    # Optional stable name for the role assignment (Azure GUID); omit to let Azure assign
    assignment_name = optional(string)
  }))
  default = {}
}
