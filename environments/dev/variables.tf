# =============================================================================
# Dev Environment - Root Module Variables
# Naming: ICR-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload> (see docs/NAMING_CONVENTION.md)
# =============================================================================

# -----------------------------------------------------------------------------
# Company-mandatory tags (set in dev.tfvars)
# -----------------------------------------------------------------------------
variable "created_by" {
  description = "Creator identity (company-mandatory tag)."
  type        = string
}

variable "created_date" {
  description = "Creation date YYYY-MM-DD (null = use apply date)."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, uat, prod)."
  type        = string
}

variable "requester" {
  description = "Requester team (company-mandatory tag)."
  type        = string
}

variable "ticket_reference" {
  description = "Ticket reference (company-mandatory tag)."
  type        = string
}

variable "project_name" {
  description = "Project name (company-mandatory tag)."
  type        = string
}

# -----------------------------------------------------------------------------
# Naming convention
# -----------------------------------------------------------------------------
variable "name_prefix" {
  description = "Naming prefix e.g. ICR-002."
  type        = string
}

variable "project_type" {
  description = "INT (internal) or CLT (client)."
  type        = string
  validation {
    condition     = contains(["INT", "CLT"], var.project_type)
    error_message = "project_type must be INT or CLT."
  }
}

variable "workload" {
  description = "Workload name e.g. Bank-Dev."
  type        = string
}

variable "location" {
  description = "Primary Azure region."
  type        = string
}

# -----------------------------------------------------------------------------
# Security - Jump VM NSG (restrict RDP/SSH in prod; use TF_VAR in CI)
# -----------------------------------------------------------------------------
variable "jump_rdp_source_cidr" {
  description = "Source CIDR allowed for RDP to jump (e.g. VPN). No 0.0.0.0/0 in prod."
  type        = string
  default     = null
}

variable "jump_ssh_source_cidr" {
  description = "Source CIDR allowed for SSH to jump. No 0.0.0.0/0 in prod."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Resource groups
# -----------------------------------------------------------------------------
variable "resource_groups" {
  description = "Map of resource groups (key = logical name)."
  type = map(object({
    name     = string
    location = optional(string)
    managed_by = optional(string)
    create_lock = optional(bool, false)
    lock_level  = optional(string, "CanNotDelete")
    tags        = optional(map(string), {})
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# VNets (optional; default {})
# -----------------------------------------------------------------------------
variable "vnets" {
  description = "Map of virtual networks with subnets and optional NSG rules."
  type = any
  default = {}
}

# -----------------------------------------------------------------------------
# Public IPs (optional)
# -----------------------------------------------------------------------------
variable "public_ips" {
  description = "Map of public IP configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# VMs - Linux (optional)
# -----------------------------------------------------------------------------
variable "vms" {
  description = "Map of Linux VM configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# VMs - Windows (optional)
# -----------------------------------------------------------------------------
variable "windows_vms" {
  description = "Map of Windows VM configurations (admin_password via TF_VAR or Key Vault)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Storage accounts (optional)
# -----------------------------------------------------------------------------
variable "storage_accounts" {
  description = "Map of storage account configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Key Vaults (optional)
# -----------------------------------------------------------------------------
variable "key_vaults" {
  description = "Map of Key Vault configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Key Vault secrets (optional; values via TF_VAR or KV)
# -----------------------------------------------------------------------------
variable "key_vault_secrets" {
  description = "Map of secrets to create in Key Vault."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# SQL servers + databases (optional)
# -----------------------------------------------------------------------------
variable "sql_servers" {
  description = "Map of SQL Server configurations (incl. databases)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Private DNS zones (optional)
# -----------------------------------------------------------------------------
variable "private_dns_zones" {
  description = "Map of Private DNS Zone configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Private endpoints (optional)
# -----------------------------------------------------------------------------
variable "private_endpoints" {
  description = "Map of private endpoint configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Container registries (optional)
# -----------------------------------------------------------------------------
variable "registries" {
  description = "Map of ACR configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Bastion hosts (optional)
# -----------------------------------------------------------------------------
variable "bastion_hosts" {
  description = "Map of Bastion host configurations (subnet_id, public_ip_id required)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# NAT gateways (optional)
# -----------------------------------------------------------------------------
variable "nat_gateways" {
  description = "Map of NAT Gateway configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# User-assigned managed identities (optional)
# -----------------------------------------------------------------------------
variable "user_assigned_identities" {
  description = "Map of user-assigned managed identity configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# MySQL Flexible servers (optional)
# -----------------------------------------------------------------------------
variable "mysql_servers" {
  description = "Map of MySQL Flexible Server configurations (passwords via TF_VAR or KV)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Redis caches (optional)
# -----------------------------------------------------------------------------
variable "redis_caches" {
  description = "Map of Azure Cache for Redis configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Log Analytics workspaces (optional)
# -----------------------------------------------------------------------------
variable "log_analytics_workspaces" {
  description = "Map of Log Analytics workspace configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Application Insights (optional)
# -----------------------------------------------------------------------------
variable "app_insights" {
  description = "Map of Application Insights configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# App Service plans + Web Apps (optional)
# -----------------------------------------------------------------------------
variable "app_service_plans" {
  description = "Map of App Service Plan configurations."
  type        = any
  default     = {}
}
variable "web_apps" {
  description = "Map of Web App configurations (reference app_service_plan_id)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Function Apps (optional)
# -----------------------------------------------------------------------------
variable "function_apps" {
  description = "Map of Function App configurations (storage key via TF_VAR or KV)."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Logic Apps (optional)
# -----------------------------------------------------------------------------
variable "logic_apps" {
  description = "Map of Logic App (Standard) configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# API Management (optional)
# -----------------------------------------------------------------------------
variable "api_managements" {
  description = "Map of API Management service configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# AKS clusters (optional)
# -----------------------------------------------------------------------------
variable "aks_clusters" {
  description = "Map of AKS cluster configurations."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Recovery Services vaults (optional)
# -----------------------------------------------------------------------------
variable "recovery_services_vaults" {
  description = "Map of Recovery Services Vault configurations."
  type        = any
  default     = {}
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

# -----------------------------------------------------------------------------
# Additional tags merged with company-mandatory
# -----------------------------------------------------------------------------
variable "additional_tags" {
  description = "Extra tags for all resources."
  type        = map(string)
  default     = {}
}
