# =============================================================================
# Prod Environment - Root Module Variables
# Same structure as dev; use prod.tfvars with stricter security (locks, PE, etc.)
# =============================================================================

variable "created_by" {
  type = string
}
variable "created_date" {
  type    = string
  default = null
}
variable "environment" {
  type = string
}
variable "requester" {
  type = string
}
variable "ticket_reference" {
  type = string
}
variable "project_name" {
  type = string
}

variable "name_prefix" {
  description = "Naming prefix e.g. ICR-002 (see docs/NAMING_CONVENTION.md)."
  type        = string
}
variable "project_type" {
  type = string
  validation {
    condition     = contains(["INT", "CLT"], var.project_type)
    error_message = "project_type must be INT or CLT."
  }
}
variable "workload" {
  type = string
}
variable "location" {
  type = string
}

variable "jump_rdp_source_cidr" {
  type    = string
  default = null
}
variable "jump_ssh_source_cidr" {
  type    = string
  default = null
}

variable "resource_groups" {
  type    = any
  default = {}
}
variable "vnets" {
  type    = any
  default = {}
}
variable "public_ips" {
  type    = any
  default = {}
}
variable "vms" {
  type    = any
  default = {}
}
variable "windows_vms" {
  type    = any
  default = {}
}
variable "storage_accounts" {
  type    = any
  default = {}
}
variable "key_vaults" {
  type    = any
  default = {}
}
variable "key_vault_secrets" {
  type    = any
  default = {}
}
variable "sql_servers" {
  type    = any
  default = {}
}
variable "private_dns_zones" {
  type    = any
  default = {}
}
variable "private_endpoints" {
  type    = any
  default = {}
}
variable "registries" {
  type    = any
  default = {}
}
variable "bastion_hosts" {
  type    = any
  default = {}
}
variable "nat_gateways" {
  type    = any
  default = {}
}
variable "user_assigned_identities" {
  type    = any
  default = {}
}
variable "mysql_servers" {
  type    = any
  default = {}
}
variable "redis_caches" {
  type    = any
  default = {}
}
variable "log_analytics_workspaces" {
  type    = any
  default = {}
}
variable "app_insights" {
  type    = any
  default = {}
}
variable "app_service_plans" {
  type    = any
  default = {}
}
variable "web_apps" {
  type    = any
  default = {}
}
variable "function_apps" {
  type    = any
  default = {}
}
variable "logic_apps" {
  type    = any
  default = {}
}
variable "api_managements" {
  type    = any
  default = {}
}
variable "aks_clusters" {
  type    = any
  default = {}
}
variable "recovery_services_vaults" {
  type    = any
  default = {}
}
# -----------------------------------------------------------------------------
# Role assignments (optional) – grant users/groups access to resources via Entra ID
# scope_type: resource_group | storage_account | key_vault | sql_server | linux_vm | windows_vm
# scope_key: logical name of the resource (e.g. main, sample). principal_id = Entra ID object ID of user/group.
# -----------------------------------------------------------------------------
variable "role_assignments" {
  description = "Reserved; not used by Terraform. Assign RBAC roles manually (Azure Portal or CLI). See docs/ACCESS_AND_ROLE_ASSIGNMENTS.md. Kept for reference only; default = {}."
  type = map(object({
    scope_type           = string # resource_group, storage_account, key_vault, sql_server, linux_vm, windows_vm
    scope_key            = string # logical key of the resource (e.g. main, sample)
    role_definition_name = string # e.g. Storage Blob Data Reader, Key Vault Secrets User, Virtual Machine Administrator Login
    principal_id         = string # Entra ID object ID (user, group, or service principal)
    principal_type       = optional(string) # User, Group, ServicePrincipal (optional; Azure may infer)
    description          = optional(string)
  }))
  default = {}
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}
