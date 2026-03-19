# When administrator_password is null (Entra ID–first), Azure still requires a value at create; use generated placeholder.
resource "random_password" "mysql_entra_placeholder" {
  for_each = { for k, v in var.mysql_servers : k => v if try(v.administrator_password, null) == null }

  length  = 32
  special = true
}

resource "azurerm_mysql_flexible_server" "mysql" {
  for_each = var.mysql_servers

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  location             = each.value.location
  administrator_login    = coalesce(each.value.administrator_login, "entraonly")
  administrator_password = coalesce(each.value.administrator_password, try(random_password.mysql_entra_placeholder[each.key].result, null))

  sku_name   = each.value.sku_name
  version    = each.value.version
  zone       = try(each.value.zone, null)

  storage {
    size_gb = each.value.storage_gb
  }

  backup_retention_days         = each.value.backup_retention_days
  geo_redundant_backup_enabled  = each.value.geo_redundant_backup_enabled

  delegated_subnet_id = try(each.value.delegated_subnet_id, null)
  private_dns_zone_id = try(each.value.private_dns_zone_id, null)

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_mysql_flexible_server_firewall_rule" "rule" {
  for_each = local.mysql_fw_rules

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql[each.value.server_key].name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

locals {
  mysql_fw_rules = merge([
    for sk, sv in var.mysql_servers : {
      for fk, fv in try(sv.firewall_rules, {}) : "${sk}-${fk}" => merge(fv, { server_key = sk, resource_group_name = sv.resource_group_name })
    }
  ]...)
}
