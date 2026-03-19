resource "azurerm_redis_cache" "redis" {
  for_each = var.redis_caches

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  capacity            = each.value.capacity
  family              = each.value.family
  sku_name            = each.value.sku_name

  non_ssl_port_enabled          = each.value.enable_non_ssl_port
  minimum_tls_version           = each.value.minimum_tls_version
  public_network_access_enabled = each.value.public_network_access_enabled

  subnet_id                     = try(each.value.subnet_id, null)
  private_static_ip_address     = try(each.value.private_static_ip_address, null)
  zones                         = length(each.value.zones) > 0 ? each.value.zones : null

  tags = merge(var.common_tags, each.value.tags)
}
