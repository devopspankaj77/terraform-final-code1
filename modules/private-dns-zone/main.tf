# =============================================================================
# Private DNS Zone - Enterprise Module
# =============================================================================

resource "azurerm_private_dns_zone" "zone" {
  for_each = var.private_dns_zones

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.common_tags, each.value.tags)
}

# for_each keys are from var.private_dns_zones only (plan-time known). vnet_id comes from var.vnet_ids (apply-time).
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = local.dns_vnet_link_keys

  name                   = "link-${each.value.link_key}"
  resource_group_name    = var.private_dns_zones[each.value.zone_key].resource_group_name
  private_dns_zone_name  = azurerm_private_dns_zone.zone[each.value.zone_key].name
  virtual_network_id    = local.link_vnet_id[each.key]
  registration_enabled  = try(var.private_dns_zones[each.value.zone_key].vnet_links[each.value.link_key].registration_enabled, false)
}

locals {
  # Keys from config only – no dependency on module outputs, so known at plan time
  dns_vnet_link_keys = merge([
    for zk, zv in var.private_dns_zones : {
      for lk in keys(try(zv.vnet_links, {})) : "${zk}-${lk}" => {
        zone_key = zk
        link_key = lk
      }
    }
  ]...)
  # Resolve vnet_id: use link.vnet_id if set, else var.vnet_ids[link.vnet_key] (passed from root)
  link_vnet_id = {
    for k, keys in local.dns_vnet_link_keys : k => coalesce(
      try(var.private_dns_zones[keys.zone_key].vnet_links[keys.link_key].vnet_id, null),
      try(var.vnet_ids[var.private_dns_zones[keys.zone_key].vnet_links[keys.link_key].vnet_key], null)
    )
  }
}
