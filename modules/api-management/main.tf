resource "azurerm_api_management" "apim" {
  for_each = var.api_managements

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  publisher_name      = each.value.publisher_name
  publisher_email     = each.value.publisher_email
  sku_name            = each.value.sku_name

  public_network_access_enabled  = each.value.public_network_access_enabled

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  tags = merge(var.common_tags, each.value.tags)
}
