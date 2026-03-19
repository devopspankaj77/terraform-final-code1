locals {
  # Provider rejects empty key. Use placeholder when using identity or when key is null/empty; runtime uses storage_uses_managed_identity + AzureWebJobsStorage__accountName for identity.
  _storage_key_placeholder = "PlaceholderKeyWhenUsingManagedIdentityLength88CharsXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  function_app_storage_key = {
    for k, v in var.function_apps : k => (
      (v.use_storage_identity || trimspace(coalesce(v.storage_account_access_key, "")) == "") ? local._storage_key_placeholder : v.storage_account_access_key
    )
  }
  function_app_app_settings_identity = {
    for k, v in var.function_apps : k => (v.use_storage_identity ? {
      "AzureWebJobsStorage__accountName" = v.storage_account_name
    } : {})
  }
}

resource "azurerm_linux_function_app" "func_linux" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Linux" }

  name                = each.value.name
  resource_group_name  = each.value.resource_group_name
  location            = each.value.location
  storage_account_name = each.value.storage_account_name
  # Provider: storage_account_access_key and storage_uses_managed_identity are mutually exclusive
  storage_account_access_key    = each.value.use_storage_identity ? null : local.function_app_storage_key[each.key]
  storage_uses_managed_identity = each.value.use_storage_identity
  service_plan_id               = each.value.app_service_plan_id

  site_config {
    application_stack {
      node_version = try(each.value.node_version, "18")
    }
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
  }

  app_settings = merge(
    each.value.app_settings,
    try(local.function_app_app_settings_identity[each.key], {}),
    {
      "FUNCTIONS_WORKER_RUNTIME" = "node"
    }
  )

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_windows_function_app" "func_windows" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Windows" }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  storage_account_name = each.value.storage_account_name
  # Provider: storage_account_access_key and storage_uses_managed_identity are mutually exclusive
  storage_account_access_key    = each.value.use_storage_identity ? null : local.function_app_storage_key[each.key]
  storage_uses_managed_identity = each.value.use_storage_identity
  service_plan_id               = each.value.app_service_plan_id

  site_config {
    application_stack {
      node_version = try(each.value.node_version, "18")
    }
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
  }

  app_settings = merge(
    each.value.app_settings,
    try(local.function_app_app_settings_identity[each.key], {}),
    {
      "FUNCTIONS_WORKER_RUNTIME" = "node"
    }
  )

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  tags = merge(var.common_tags, each.value.tags)
}

# Entra ID (managed identity) access to storage when use_storage_identity = true and create_storage_rbac = true (skip when runner lacks roleAssignments/write)
resource "azurerm_role_assignment" "func_linux_storage_blob" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Linux" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.func_linux[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "func_linux_storage_queue" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Linux" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_linux_function_app.func_linux[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "func_linux_storage_table" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Linux" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_function_app.func_linux[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "func_windows_storage_blob" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Windows" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_function_app.func_windows[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "func_windows_storage_queue" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Windows" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_windows_function_app.func_windows[each.key].identity[0].principal_id
}

resource "azurerm_role_assignment" "func_windows_storage_table" {
  for_each = { for k, v in var.function_apps : k => v if try(v.os_type, "Linux") == "Windows" && v.use_storage_identity && try(v.create_storage_rbac, true) }

  scope                = each.value.storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_windows_function_app.func_windows[each.key].identity[0].principal_id
}
