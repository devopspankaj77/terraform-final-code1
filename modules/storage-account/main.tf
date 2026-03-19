# =============================================================================
# Storage Account - Enterprise Module
# Security: HTTPS only, min TLS 1.2, blob/container soft delete, network rules
# =============================================================================

resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  account_tier        = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind        = each.value.account_kind
  access_tier         = each.value.access_tier

  https_traffic_only_enabled      = each.value.enable_https_traffic_only
  min_tls_version                 = each.value.min_tls_version
  allow_nested_items_to_be_public = each.value.allow_nested_items_to_be_public
  public_network_access_enabled   = each.value.public_network_access_enabled
  shared_access_key_enabled       = each.value.shared_access_key_enabled

  dynamic "network_rules" {
    for_each = each.value.network_rules != null ? [each.value.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                      = network_rules.value.bypass
      ip_rules                    = network_rules.value.ip_rules
      virtual_network_subnet_ids   = network_rules.value.virtual_network_subnet_ids
      dynamic "private_link_access" {
        for_each = try(network_rules.value.private_link_access, [])
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id  = try(private_link_access.value.endpoint_tenant_id, null)
        }
      }
    }
  }

  blob_properties {
    versioning_enabled  = each.value.enable_blob_versioning
    last_access_time_enabled = each.value.last_access_time_enabled

    delete_retention_policy {
      days = each.value.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = each.value.container_soft_delete_retention_days
    }
  }

  # Identity required when using customer-managed key (system-assigned or user-assigned)
  dynamic "identity" {
    for_each = each.value.customer_managed_key != null ? [1] : []
    content {
      type         = try(each.value.customer_managed_key.user_assigned_identity_id, null) != null ? "UserAssigned" : "SystemAssigned"
      identity_ids = try(each.value.customer_managed_key.user_assigned_identity_id, null) != null ? [each.value.customer_managed_key.user_assigned_identity_id] : null
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}

# Customer-managed key (CMK) encryption for storage account; grant storage identity Key Vault Crypto User on the key
resource "azurerm_storage_account_customer_managed_key" "cmk" {
  for_each = { for k, v in var.storage_accounts : k => v if v.customer_managed_key != null }

  storage_account_id        = azurerm_storage_account.sa[each.key].id
  key_vault_id              = each.value.customer_managed_key.key_vault_id
  key_name                  = each.value.customer_managed_key.key_name
  key_version                = try(each.value.customer_managed_key.key_version, null)
  user_assigned_identity_id = try(each.value.customer_managed_key.user_assigned_identity_id, null)
}

resource "azurerm_storage_container" "container" {
  for_each = local.containers_flat

  name                  = each.value.name
  storage_account_id     = azurerm_storage_account.sa[each.value.sa_key].id
  container_access_type = each.value.access_type
  metadata              = try(each.value.metadata, {})
}

locals {
  containers_flat = merge([
    for sak, sav in var.storage_accounts : {
      for ck, cv in try(sav.containers, {}) : "${sak}-${ck}" => merge(cv, { sa_key = sak })
    }
  ]...)
}

resource "azurerm_management_lock" "sa_lock" {
  for_each = { for k, v in var.storage_accounts : k => v if try(v.create_delete_lock, false) }

  name       = "${each.value.name}-lock"
  scope      = azurerm_storage_account.sa[each.key].id
  lock_level = each.value.lock_level
}
