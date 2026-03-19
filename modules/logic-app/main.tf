locals {
  # Logic App Standard does not support managed-identity-only storage in the provider; use_storage_identity is always false from root. Use placeholder only when use_storage_identity is true; otherwise pass key as-is (must be valid if non-null).
  _logic_app_key_placeholder = "PlaceholderKeyWhenUsingManagedIdentityLength88CharsXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  logic_app_storage_key = {
    for k, v in var.logic_apps : k => (
      v.use_storage_identity ? local._logic_app_key_placeholder : coalesce(v.storage_account_access_key, "")
    )
  }
  logic_app_app_settings_identity = {
    for k, v in var.logic_apps : k => (v.use_storage_identity ? {
      "AzureWebJobsStorage__accountName" = v.storage_account_name
    } : {})
  }
}

resource "azurerm_logic_app_standard" "logic_app" {
  for_each = var.logic_apps

  name                       = each.value.name
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  app_service_plan_id        = each.value.app_service_plan_id
  storage_account_name       = each.value.storage_account_name
  storage_account_access_key = local.logic_app_storage_key[each.key]

  app_settings = try(local.logic_app_app_settings_identity[each.key], {})

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.common_tags, each.value.tags)
}

# Entra ID (managed identity) access to storage when use_storage_identity = true (for_each key must be static; scope may be known after apply)
resource "azurerm_role_assignment" "logic_app_storage_blob" {
  for_each = { for k, v in var.logic_apps : k => v if v.use_storage_identity }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_logic_app_standard.logic_app[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "logic_app_storage_queue" {
  for_each = { for k, v in var.logic_apps : k => v if v.use_storage_identity }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_logic_app_standard.logic_app[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "logic_app_storage_table" {
  for_each = { for k, v in var.logic_apps : k => v if v.use_storage_identity }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_logic_app_standard.logic_app[each.key].identity[0].principal_id
}
