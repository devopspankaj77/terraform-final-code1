# =============================================================================
# Resource Group - Enterprise Module
# Security: optional delete lock; full tagging
# =============================================================================

resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location
  tags     = merge(var.common_tags, each.value.tags)

  managed_by = try(each.value.managed_by, null)
}

resource "azurerm_management_lock" "rg_lock" {
  for_each = {
    for k, v in var.resource_groups : k => v
    if try(v.create_lock, false)
  }

  name       = coalesce(each.value.lock_name, "${each.key}-lock")
  scope      = azurerm_resource_group.rg[each.key].id
  lock_level = each.value.lock_level
}
