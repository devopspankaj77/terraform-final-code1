resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_clusters

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  dns_prefix          = each.value.dns_prefix

  default_node_pool {
    name                = each.value.default_node_pool.name
    vm_size             = each.value.default_node_pool.vm_size
    node_count          = each.value.default_node_pool.node_count
    vnet_subnet_id      = try(each.value.default_node_pool.vnet_subnet_id, null)
  }

  identity {
    type         = each.value.identity_type
    identity_ids = each.value.identity_type == "UserAssigned" || each.value.identity_type == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  azure_policy_enabled = true
  role_based_access_control_enabled = true

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = length(try(each.value.admin_group_object_ids, [])) > 0 ? [1] : []
    content {
      admin_group_object_ids = each.value.admin_group_object_ids
    }
  }

  dynamic "network_profile" {
    for_each = each.value.network_profile != null && each.value.network_profile != {} ? [each.value.network_profile] : []
    content {
      network_plugin    = try(network_profile.value.network_plugin, "azure")
      network_policy    = try(network_profile.value.network_policy, "azure")
      load_balancer_sku = try(network_profile.value.load_balancer_sku, "standard")
      # Avoid ServiceCidrOverlapExistingSubnetsCidr: use a CIDR outside VNet (e.g. VNet 10.0.0.0/16 -> service 172.16.0.0/16)
      service_cidr      = try(network_profile.value.service_cidr, "172.16.0.0/16")
      dns_service_ip    = try(network_profile.value.dns_service_ip, "172.16.0.10")
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}
