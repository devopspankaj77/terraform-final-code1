# =============================================================================
# Virtual Network - Enterprise Module
# Security: NSG; explicit rules only; optional PE subnet (policies disabled)
# =============================================================================

# Virtual networks
resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnets

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space
  dns_servers         = length(coalesce(each.value.dns_servers, [])) > 0 ? each.value.dns_servers : null
  tags                = merge(var.common_tags, each.value.tags)
}

# Subnets (excluding PE subnet which is separate)
resource "azurerm_subnet" "subnet" {
  for_each = local.all_subnets

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies = try(each.value.allow_private_endpoint, false) ? "Disabled" : "Enabled"
  service_endpoints                 = try(each.value.service_endpoints, [])

  dynamic "delegation" {
    for_each = try(each.value.delegation, null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

locals {
  all_subnets = merge([
    for vk, vv in var.vnets : {
      for sk, sv in vv.subnets : "${vk}-${sk}" => merge(sv, {
        vnet_key            = vk
        resource_group_name = vv.resource_group_name
      })
    }
  ]...)
}

# Dedicated subnet for private endpoints (network policies disabled)
resource "azurerm_subnet" "pe_subnet" {
  for_each = { for k, v in var.vnets : k => v if try(v.create_private_endpoint_subnet, false) }

  name                 = "snet-privateendpoints"
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = [try(each.value.private_endpoint_subnet_prefix, "10.0.254.0/24")]

  private_endpoint_network_policies = "Disabled"
}

# NSG for private endpoint subnet (when nsg_per_subnet = true and create_private_endpoint_subnet = true)
resource "azurerm_network_security_group" "pe_subnet_nsg" {
  for_each = { for k, v in var.vnets : k => v if try(v.create_nsg, true) && try(v.nsg_per_subnet, false) && try(v.create_private_endpoint_subnet, false) }

  name                = "snet-privateendpoints-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.common_tags, each.value.tags)
}

resource "azurerm_network_security_rule" "pe_subnet_nsg_rule" {
  for_each = local.pe_subnet_nsg_rules

  name                         = each.value.rule.name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = coalesce(each.value.rule.protocol, "*")
  source_port_range            = coalesce(each.value.rule.source_port_range, "*")
  destination_port_range       = each.value.rule.destination_port_range
  source_address_prefix        = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.source_address_prefix, null), "*")
  source_address_prefixes      = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? each.value.rule.source_address_prefixes : null
  destination_address_prefix  = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.destination_address_prefix, null), "*")
  destination_address_prefixes = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? each.value.rule.destination_address_prefixes : null
  resource_group_name          = each.value.resource_group_name
  network_security_group_name  = azurerm_network_security_group.pe_subnet_nsg[each.value.vnet_key].name
}

locals {
  pe_subnet_nsg_rules = merge([
    for vk, vv in var.vnets : {
      for rk, rv in try(vv.pe_subnet_nsg_rules, {}) : "${vk}-${rk}" => {
        vnet_key            = vk
        resource_group_name = vv.resource_group_name
        rule                = rv
      }
    } if try(vv.create_nsg, true) && try(vv.nsg_per_subnet, false) && try(vv.create_private_endpoint_subnet, false)
  ]...)
}

resource "azurerm_subnet_network_security_group_association" "pe_subnet_nsg" {
  for_each = { for k, v in var.vnets : k => v if try(v.create_nsg, true) && try(v.nsg_per_subnet, false) && try(v.create_private_endpoint_subnet, false) }

  subnet_id                 = azurerm_subnet.pe_subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.pe_subnet_nsg[each.key].id
}

# One NSG per VNet (when create_nsg true and not per-subnet)
resource "azurerm_network_security_group" "vnet_nsg" {
  for_each = { for k, v in var.vnets : k => v if try(v.create_nsg, true) && !try(v.nsg_per_subnet, false) }

  name                = "${each.value.name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.common_tags, each.value.tags)
}

# NSG rules for vnet-level NSG (only one of source/destination prefix vs prefixes can be set per Azure API)
resource "azurerm_network_security_rule" "vnet_nsg_rule" {
  for_each = local.vnet_nsg_rules

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = coalesce(each.value.rule.protocol, "*")
  source_port_range           = coalesce(each.value.rule.source_port_range, "*")
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.source_address_prefix, null), "*")
  source_address_prefixes     = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? each.value.rule.source_address_prefixes : null
  destination_address_prefix  = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.destination_address_prefix, null), "*")
  destination_address_prefixes = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? each.value.rule.destination_address_prefixes : null
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = azurerm_network_security_group.vnet_nsg[each.value.vnet_key].name
}

locals {
  vnet_nsg_rules = merge([
    for vk, vv in var.vnets : {
      for rk, rv in try(vv.nsg_rules, {}) : "${vk}-${rk}" => {
        vnet_key            = vk
        resource_group_name = vv.resource_group_name
        rule                = rv
      }
    } if try(vv.create_nsg, true) && !try(vv.nsg_per_subnet, false)
  ]...)
}

# Associate vnet NSG to all subnets of that vnet
resource "azurerm_subnet_network_security_group_association" "vnet_nsg" {
  for_each = local.vnet_nsg_assoc

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.vnet_nsg[each.value.vnet_key].id
}

locals {
  vnet_nsg_assoc = merge([
    for vk, vv in var.vnets : {
      for sk in keys(try(vv.subnets, {})) : "${vk}-${sk}" => { vnet_key = vk }
    } if try(vv.create_nsg, true) && !try(vv.nsg_per_subnet, false)
  ]...)
}

# Per-subnet NSGs (when nsg_per_subnet = true)
resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = local.subnet_nsg_map

  name                = "${each.value.subnet_name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.common_tags, each.value.tags)
}

# Exclude AzureBastionSubnet from per-subnet NSG: Azure requires a specific NSG rule set for Bastion; attaching generic rules causes NetworkSecurityGroupNotCompliantForAzureBastionSubnet.
locals {
  subnet_nsg_map = merge([
    for vk, vv in var.vnets : {
      for sk, sv in vv.subnets : "${vk}-${sk}" => {
        subnet_name         = sv.name
        location            = vv.location
        resource_group_name = vv.resource_group_name
        tags                = vv.tags
      } if sv.name != "AzureBastionSubnet"
    } if try(vv.create_nsg, true) && try(vv.nsg_per_subnet, false)
  ]...)
}

resource "azurerm_network_security_rule" "subnet_nsg_rule" {
  for_each = local.subnet_nsg_rules

  name                         = each.value.rule.name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = coalesce(each.value.rule.protocol, "*")
  source_port_range            = coalesce(each.value.rule.source_port_range, "*")
  destination_port_range       = each.value.rule.destination_port_range
  source_address_prefix        = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.source_address_prefix, null), "*")
  source_address_prefixes      = length(try(each.value.rule.source_address_prefixes, [])) > 0 ? each.value.rule.source_address_prefixes : null
  destination_address_prefix   = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? null : coalesce(try(each.value.rule.destination_address_prefix, null), "*")
  destination_address_prefixes = length(try(each.value.rule.destination_address_prefixes, [])) > 0 ? each.value.rule.destination_address_prefixes : null
  resource_group_name          = each.value.resource_group_name
  network_security_group_name  = azurerm_network_security_group.subnet_nsg[each.value.nsg_key].name
}

# Subnet-specific NSG rules: each subnet uses its own nsg_rules if set, else vnet-level nsg_rules (exclude AzureBastionSubnet)
locals {
  subnet_nsg_rules = merge(flatten([
    for vk, vv in var.vnets :
    (try(vv.create_nsg, true) && try(vv.nsg_per_subnet, false)) ? [
      for sk, sv in try(vv.subnets, {}) :
      try(sv.name, "") != "AzureBastionSubnet" ? [
        for rk, rv in (length(try(sv.nsg_rules, {})) > 0 ? sv.nsg_rules : try(vv.nsg_rules, {})) :
        { "${vk}-${sk}-${rk}" = { nsg_key = "${vk}-${sk}", resource_group_name = vv.resource_group_name, rule = rv } }
      ] : []
    ] : []
  ])...)
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each = local.subnet_nsg_map

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id
}
