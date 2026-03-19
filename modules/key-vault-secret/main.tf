# =============================================================================
# Key Vault Secret - Enterprise Module
# =============================================================================

resource "azurerm_key_vault_secret" "secret" {
  for_each = var.secrets

  name         = each.value.name
  value        = each.value.value
  key_vault_id = each.value.key_vault_id
  content_type = try(each.value.content_type, null)
  tags         = merge(var.common_tags, try(each.value.tags, {}))
}
