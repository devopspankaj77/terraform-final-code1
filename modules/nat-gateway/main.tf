resource "azurerm_nat_gateway" "ngw" {
  for_each = var.nat_gateways

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku_name            = each.value.sku_name
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  zones               = length(each.value.zones) > 0 ? each.value.zones : null

  tags = merge(var.common_tags, each.value.tags)
}
