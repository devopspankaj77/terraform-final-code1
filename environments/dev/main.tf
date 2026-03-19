# =============================================================================
# Dev Environment - Enterprise Root Module
# Uses for_each at root: one module instance per item; target e.g. module.resource_group["main"]
# Data sources: client config; subnet/plan IDs resolved from module outputs for VMs and Web Apps.
# =============================================================================

data "azurerm_client_config" "current" {}

# Resolve subnet_id for VMs from vnet module when vnet_key and subnet_key are set in tfvars
locals {
  vms_resolved = {
    for k, v in var.vms : k => merge(v, {
      subnet_id = coalesce(
        try(v.subnet_id, null),
        try(module.vnet[v.vnet_key].subnet_ids["${v.vnet_key}-${v.subnet_key}"], null)
      )
    })
  }
  windows_vms_resolved = {
    for k, v in var.windows_vms : k => merge(v, {
      subnet_id = coalesce(
        try(v.subnet_id, null),
        try(module.vnet[v.vnet_key].subnet_ids["${v.vnet_key}-${v.subnet_key}"], null)
      )
    })
  }
  # vnet_key -> vnet_id for private DNS zone links (so module for_each keys stay plan-time known)
  vnet_ids_for_dns = {
    for vk in distinct(flatten([for zk, zv in var.private_dns_zones : [for lk, lv in try(zv.vnet_links, {}) : try(lv.vnet_key, "")]])) : vk => module.vnet[vk].vnet_ids[vk] if vk != ""
  }
  # Resolve private endpoints: vnet_key + target_type/target_key -> subnet_id, resource_id
  private_endpoints_resolved = {
    for pk, pv in var.private_endpoints : pk => merge(pv, {
      subnet_id = coalesce(
        try(pv.subnet_id, null),
        try(module.vnet[pv.vnet_key].pe_subnet_ids[pv.vnet_key], null)
      )
      resource_id = coalesce(
        try(pv.resource_id, null),
        try(
          pv.target_type == "storage_account" ? module.storage_account[pv.target_key].ids[pv.target_key] :
          pv.target_type == "key_vault" ? module.keyvault[pv.target_key].ids[pv.target_key] :
          pv.target_type == "sql_server" ? module.sql[pv.target_key].server_ids[pv.target_key] :
          null,
          null
        )
      )
    })
  }
  # Resolve bastion: vnet_key + subnet_key + public_ip_key -> subnet_id, public_ip_id
  bastion_hosts_resolved = {
    for bk, bv in var.bastion_hosts : bk => merge(bv, {
      subnet_id    = try(module.vnet[bv.vnet_key].subnet_ids["${bv.vnet_key}-${bv.subnet_key}"], bv.subnet_id)
      public_ip_id = try(module.public_ip[bv.public_ip_key].ids[bv.public_ip_key], bv.public_ip_id)
    })
  }
  # Resolve function apps: storage_account_key + app_service_plan_key -> storage name/key, plan_id; use_storage_identity when shared key disabled
  function_apps_resolved = {
    for fk, fv in var.function_apps : fk => merge(fv, {
      storage_account_name       = try(module.storage_account[fv.storage_account_key].names[fv.storage_account_key], fv.storage_account_name)
      storage_account_access_key = try(module.storage_account[fv.storage_account_key].primary_access_keys[fv.storage_account_key], null)
      use_storage_identity       = !try(var.storage_accounts[fv.storage_account_key].shared_access_key_enabled, false)
      storage_account_id         = try(module.storage_account[fv.storage_account_key].ids[fv.storage_account_key], null)
      app_service_plan_id        = try(module.app_service["default"].plan_ids[fv.app_service_plan_key], fv.app_service_plan_id)
    })
  }
  # Resolve logic apps: storage_account_key + app_service_plan_key. Logic App Standard requires a valid storage key (no managed-identity-only in provider); use_storage_identity always false.
  logic_apps_resolved = {
    for lk, lv in var.logic_apps : lk => merge(lv, {
      storage_account_name       = try(module.storage_account[lv.storage_account_key].names[lv.storage_account_key], lv.storage_account_name)
      storage_account_access_key = try(module.storage_account[lv.storage_account_key].primary_access_keys[lv.storage_account_key], null)
      use_storage_identity      = false
      storage_account_id        = try(module.storage_account[lv.storage_account_key].ids[lv.storage_account_key], null)
      app_service_plan_id       = try(module.app_service["default"].plan_ids[lv.app_service_plan_key], lv.app_service_plan_id)
    })
  }
  # Resolve AKS default_node_pool: vnet_key + subnet_key -> vnet_subnet_id
  aks_resolved = {
    for ak, av in var.aks_clusters : ak => merge(av, {
      default_node_pool = merge(av.default_node_pool, {
        vnet_subnet_id = coalesce(
          try(av.default_node_pool.vnet_subnet_id, null),
          try(module.vnet[av.default_node_pool.vnet_key].subnet_ids["${av.default_node_pool.vnet_key}-${av.default_node_pool.subnet_key}"], null)
        )
      })
    })
  }

  # First octets of all VNet/subnet CIDRs (for AKS service_cidr conflict check at plan time).
  # Normalize so we always get list(string): flatten([[x]]) works for both string and list.
  _vnet_address_space_list = [for v in var.vnets : flatten([[try(v.address_space, [])]])]
  _vnet_subnet_prefix_list = [for v in var.vnets : [for sk, sv in try(v.subnets, {}) : flatten([[try(sv.address_prefixes, [])]])]]
  vnet_cidr_first_octets = toset(compact(flatten(concat(
    [for cidrs in local._vnet_address_space_list : [for a in cidrs : try(split(".", split(a, "/")[0])[0], "")]],
    [for per_vnet in local._vnet_subnet_prefix_list : [for cidrs in per_vnet : [for ap in cidrs : try(split(".", split(ap, "/")[0])[0], "")]]],
    [for v in var.vnets : try(v.create_private_endpoint_subnet, false) && try(v.private_endpoint_subnet_prefix, "") != "" ? [try(split(".", split(v.private_endpoint_subnet_prefix, "/")[0])[0], "")] : []]
  ))))
  # Only consider numeric first octets for overlap (ignore stray non-numeric from malformed CIDRs)
  vnet_cidr_first_octets_numeric = toset([for o in local.vnet_cidr_first_octets : o if length(regexall("^[0-9]+$", o)) > 0])

  # AKS service_cidr must not share first octet with VNet (avoids ServiceCidrOverlapExistingSubnetsCidr)
  aks_service_cidr_conflicts = [
    for ak, av in var.aks_clusters :
    ak
    if try(av.network_profile, null) != null && try(av.network_profile, {}) != {} && contains(local.vnet_cidr_first_octets_numeric, try(split(".", split(try(av.network_profile.service_cidr, "172.16.0.0/16"), "/")[0])[0], ""))
  ]
  # For clearer errors: show which first octets are in use
  vnet_first_octets_str   = join(", ", sort(local.vnet_cidr_first_octets_numeric))
  aks_conflict_detail_str = length(local.aks_service_cidr_conflicts) > 0 ? "VNet/subnet first octet(s): ${local.vnet_first_octets_str != "" ? local.vnet_first_octets_str : "(none)"}. Use network_profile.service_cidr with a different first octet (e.g. if VNet is 10.x use service_cidr=\"172.16.0.0/16\" and dns_service_ip=\"172.16.0.10\"; if VNet is 172.x use service_cidr=\"10.0.0.0/16\" and dns_service_ip=\"10.0.0.10\")." : ""
}

# Resource groups
module "resource_group" {
  source   = "../../modules/resource-group"
  for_each = var.resource_groups

  resource_groups = {
    (each.key) = {
      name         = each.value.name
      location     = coalesce(try(each.value.location, null), var.location)
      tags         = merge(local.common_tags, try(each.value.tags, {}))
      managed_by   = try(each.value.managed_by, null)
      create_lock  = try(each.value.create_lock, false)
      lock_level   = try(each.value.lock_level, "CanNotDelete")
      lock_name    = try(each.value.lock_name, null)
    }
  }
  common_tags = local.common_tags
}

# Virtual networks (depend on RG so Azure has the RG before creating VNet/NSGs)
module "vnet" {
  source   = "../../modules/vnet"
  for_each = var.vnets

  vnets = {
    (each.key) = merge(each.value, { tags = merge(local.common_tags, try(each.value.tags, {})) })
  }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Public IPs (standalone; e.g. for Bastion, NAT)
module "public_ip" {
  source   = "../../modules/azurerm_public_ip"
  for_each = var.public_ips

  public_ips = {
    (each.key) = merge(each.value, { tags = merge(local.common_tags, try(each.value.tags, {})) })
  }

  depends_on = [module.resource_group]
}

# Linux VMs (subnet_id resolved from module.vnet when vnet_key/subnet_key set in tfvars)
module "vm" {
  source   = "../../modules/vm"
  for_each = var.vms

  vms         = { (each.key) = local.vms_resolved[each.key] }
  common_tags = local.common_tags

  depends_on = [module.resource_group, module.vnet]
}

# Windows VMs (subnet_id resolved from module.vnet when vnet_key/subnet_key set in tfvars)
module "vm_windows" {
  source   = "../../modules/vm-windows"
  for_each = var.windows_vms

  vms         = { (each.key) = local.windows_vms_resolved[each.key] }
  common_tags = local.common_tags

  depends_on = [module.resource_group, module.vnet]
}

# Storage accounts
module "storage_account" {
  source   = "../../modules/storage-account"
  for_each = var.storage_accounts

  storage_accounts = { (each.key) = each.value }
  common_tags      = local.common_tags

  depends_on = [module.resource_group]
}

# Key Vaults
module "keyvault" {
  source   = "../../modules/keyvault"
  for_each = var.key_vaults

  key_vaults  = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Key Vault secrets
module "key_vault_secret" {
  source   = "../../modules/key-vault-secret"
  for_each = var.key_vault_secrets

  secrets    = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# SQL servers + databases
module "sql" {
  source   = "../../modules/sql"
  for_each = var.sql_servers

  sql_servers = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Private DNS zones (pass raw var so for_each keys are known; vnet_ids from root for link resolution)
module "private_dns_zone" {
  source   = "../../modules/private-dns-zone"
  for_each = var.private_dns_zones

  private_dns_zones = { (each.key) = each.value }
  vnet_ids          = local.vnet_ids_for_dns
  common_tags       = local.common_tags

  depends_on = [module.resource_group, module.vnet]
}

# Private endpoints (subnet_id, resource_id resolved from vnet_key + target_type/target_key in root)
module "private_endpoint" {
  source   = "../../modules/private-endpoint"
  for_each = local.private_endpoints_resolved

  private_endpoints = { (each.key) = each.value }
  common_tags       = local.common_tags

  depends_on = [module.resource_group, module.vnet, module.storage_account, module.keyvault, module.sql]
}

# Container registries
module "registry" {
  source   = "../../modules/registry"
  for_each = var.registries

  registries  = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Bastion hosts (subnet_id, public_ip_id resolved from vnet_key/subnet_key/public_ip_key in root)
module "bastion" {
  source   = "../../modules/bastion"
  for_each = local.bastion_hosts_resolved

  bastion_hosts = { (each.key) = each.value }
  common_tags   = local.common_tags

  depends_on = [module.resource_group, module.vnet, module.public_ip]
}

# NAT gateways
module "nat_gateway" {
  source   = "../../modules/nat-gateway"
  for_each = var.nat_gateways

  nat_gateways = { (each.key) = each.value }
  common_tags  = local.common_tags

  depends_on = [module.resource_group]
}

# User-assigned managed identities
module "user_assigned_identity" {
  source   = "../../modules/user-assigned-identity"
  for_each = var.user_assigned_identities

  identities  = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# MySQL Flexible servers
module "mysql_flexible" {
  source   = "../../modules/mysql-flexible"
  for_each = var.mysql_servers

  mysql_servers = { (each.key) = each.value }
  common_tags   = local.common_tags

  depends_on = [module.resource_group]
}

# Redis caches
module "redis" {
  source   = "../../modules/redis"
  for_each = var.redis_caches

  redis_caches = { (each.key) = each.value }
  common_tags  = local.common_tags

  depends_on = [module.resource_group]
}

# Log Analytics workspaces
module "log_analytics" {
  source   = "../../modules/log-analytics"
  for_each = var.log_analytics_workspaces

  workspaces  = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Application Insights
module "application_insights" {
  source   = "../../modules/application-insights"
  for_each = var.app_insights

  app_insights = { (each.key) = each.value }
  common_tags  = local.common_tags

  depends_on = [module.resource_group]
}

# App Service plans + Web Apps (one module instance with full maps; plans and web_apps are related)
module "app_service" {
  source   = "../../modules/app-service"
  for_each = length(var.app_service_plans) > 0 ? toset(["default"]) : toset([])

  app_service_plans = var.app_service_plans
  web_apps          = var.web_apps
  common_tags       = local.common_tags

  depends_on = [module.resource_group]
}

# Function Apps (storage + plan resolved from storage_account_key/app_service_plan_key in root)
module "function_app" {
  source   = "../../modules/function-app"
  for_each = local.function_apps_resolved

  function_apps = { (each.key) = each.value }
  common_tags   = local.common_tags

  depends_on = [module.resource_group, module.storage_account, module.app_service]
}

# Logic Apps (storage + plan resolved from storage_account_key/app_service_plan_key in root)
module "logic_app" {
  source   = "../../modules/logic-app"
  for_each = local.logic_apps_resolved

  logic_apps  = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group, module.storage_account, module.app_service]
}

# API Management
module "api_management" {
  source   = "../../modules/api-management"
  for_each = var.api_managements

  api_managements = { (each.key) = each.value }
  common_tags     = local.common_tags

  depends_on = [module.resource_group]
}

# AKS clusters (default_node_pool.vnet_subnet_id resolved from vnet_key/subnet_key in root)
module "aks" {
  source   = "../../modules/aks"
  for_each = local.aks_resolved

  aks_clusters = { (each.key) = each.value }
  common_tags  = local.common_tags

  depends_on = [module.resource_group, module.vnet]
}

# Recovery Services vaults
module "recovery_services_vault" {
  source   = "../../modules/recovery-services-vault"
  for_each = var.recovery_services_vaults

  vaults      = { (each.key) = each.value }
  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Role assignments are not created by Terraform; assign RBAC manually via Azure Portal or CLI (see docs/ACCESS_AND_ROLE_ASSIGNMENTS.md).
