resource "azurerm_application_insights" "ai" {
  for_each = var.app_insights

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  application_type    = each.value.application_type
  workspace_id        = try(each.value.workspace_id, null)
  retention_in_days   = try(each.value.retention_in_days, null)
  sampling_percentage = try(each.value.sampling_percentage, null)

  tags = merge(var.common_tags, each.value.tags)
}
