resource "azurerm_service_plan" "plan" {
  for_each = var.app_service_plans

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_linux_web_app" "app_linux" {
  for_each = { for k, v in var.web_apps : k => v if try(v.os_type, "Linux") == "Linux" }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  service_plan_id     = try(azurerm_service_plan.plan[each.value.app_service_plan_key].id, each.value.app_service_plan_id)

  https_only = each.value.https_only

  app_settings = each.value.app_settings
  dynamic "connection_string" {
    for_each = each.value.connection_string
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  site_config {
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
    always_on           = each.value.always_on
  }

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_windows_web_app" "app_windows" {
  for_each = { for k, v in var.web_apps : k => v if try(v.os_type, "Linux") == "Windows" }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  service_plan_id      = try(azurerm_service_plan.plan[each.value.app_service_plan_key].id, each.value.app_service_plan_id)

  https_only = each.value.https_only

  app_settings = each.value.app_settings
  dynamic "connection_string" {
    for_each = each.value.connection_string
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  site_config {
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
    always_on           = each.value.always_on
  }

  tags = merge(var.common_tags, each.value.tags)
}
