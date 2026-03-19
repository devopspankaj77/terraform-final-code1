resource "azurerm_log_analytics_workspace" "workspace" {
  for_each = var.workspaces

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku
  retention_in_days   = each.value.retention_in_days
  daily_quota_gb      = try(each.value.daily_quota_gb, null)

  tags = merge(var.common_tags, each.value.tags)
}
