resource "azurerm_recovery_services_vault" "vault" {
  for_each = var.vaults

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku
  soft_delete_enabled = each.value.soft_delete_enabled

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_management_lock" "lock" {
  for_each = { for k, v in var.vaults : k => v if try(v.create_lock, false) }

  name       = "${each.value.name}-lock"
  scope      = azurerm_recovery_services_vault.vault[each.key].id
  lock_level = each.value.lock_level
}
