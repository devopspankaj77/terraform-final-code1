resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion_hosts

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = coalesce(each.value.sku, "Standard")

  ip_configuration {
    name                 = "configuration"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = each.value.public_ip_id
  }

  copy_paste_enabled     = each.value.copy_paste_enabled
  file_copy_enabled      = each.value.file_copy_enabled
  # ip_connect_enabled is only supported when sku is Standard or Premium; Azure returns error otherwise
  ip_connect_enabled     = (coalesce(each.value.sku, "Standard") == "Standard" || coalesce(each.value.sku, "Standard") == "Premium") ? each.value.ip_connect_enabled : false
  scale_units            = each.value.scale_units
  shareable_link_enabled = each.value.shareable_link_enabled
  tunneling_enabled      = each.value.tunneling_enabled

  tags = merge(var.common_tags, each.value.tags)
}
