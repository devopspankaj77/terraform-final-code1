# =============================================================================
# Key Vault Secret - Enterprise Module Variables
# Spec: key_vault_id, name, value (required); content_type (optional). Value via TF_VAR or KV.
# =============================================================================

variable "secrets" {
  description = "Map of secrets to create in Key Vault. RBAC: identity needs Key Vault Secrets Officer."
  type = map(object({
    key_vault_id = string
    name         = string
    value        = string            # sensitive; never commit
    content_type = optional(string)
    tags         = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each secret's tags."
  type        = map(string)
  default     = {}
}
