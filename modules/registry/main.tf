# =============================================================================
# Azure Container Registry - Enterprise Module
# Security: admin_enabled = false; public_network_access_enabled = false with PE
# =============================================================================

resource "azurerm_container_registry" "acr" {
  for_each = var.registries

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  quarantine_policy_enabled     = each.value.quarantine_policy_enabled
  anonymous_pull_enabled       = each.value.anonymous_pull_enabled
  data_endpoint_enabled        = each.value.data_endpoint_enabled
  network_rule_bypass_option   = try(each.value.network_rule_bypass_option, "AzureServices")

  # retention_policy / trust_policy: configure via Azure Portal or separate resource if needed
  dynamic "encryption" {
    for_each = each.value.encryption != null && try(each.value.encryption.enabled, false) ? [each.value.encryption] : []
    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  # network_rule_set: Premium SKU only; use ip_rule for allowlist; VNet rules via private endpoint
  dynamic "network_rule_set" {
    for_each = try(each.value.network_rule_set, null) != null ? [each.value.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action
      dynamic "ip_rule" {
        for_each = try(network_rule_set.value.ip_rule, [])
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}
