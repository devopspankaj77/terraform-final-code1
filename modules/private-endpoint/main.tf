# =============================================================================
# Private Endpoint - Enterprise Module
# =============================================================================

resource "azurerm_private_endpoint" "pe" {
  for_each = var.private_endpoints

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "${each.value.name}-psc"
    private_connection_resource_id = each.value.resource_id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = try(each.value.private_dns_zone_id, null) != null ? [1] : []
    content {
      name                 = coalesce(each.value.private_dns_zone_group_name, "default")
      private_dns_zone_ids  = [each.value.private_dns_zone_id]
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}
