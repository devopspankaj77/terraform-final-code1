# =============================================================================
# Key Vault - Enterprise Module
# Security: RBAC only, soft delete 90d, purge protection, network_acls
# =============================================================================

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  for_each = var.key_vaults

  name                        = each.value.name
  location                    = each.value.location
  resource_group_name         = each.value.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = each.value.sku_name
  enabled_for_disk_encryption = each.value.enabled_for_disk_encryption
  enabled_for_deployment      = each.value.enabled_for_deployment
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  rbac_authorization_enabled  = each.value.enable_rbac_authorization
  soft_delete_retention_days  = each.value.soft_delete_retention_days
  purge_protection_enabled    = each.value.purge_protection_enabled
  public_network_access_enabled = each.value.public_network_access_enabled

  dynamic "network_acls" {
    for_each = each.value.network_acls != null ? [each.value.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = try(network_acls.value.ip_rules, [])
      virtual_network_subnet_ids = try(network_acls.value.virtual_network_subnet_ids, [])
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_management_lock" "kv_lock" {
  for_each = { for k, v in var.key_vaults : k => v if try(v.create_delete_lock, false) }

  name       = "${each.value.name}-lock"
  scope      = azurerm_key_vault.kv[each.key].id
  lock_level = each.value.lock_level
}
