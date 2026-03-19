output "vnet_ids" {
  description = "Map of virtual network IDs."
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.id }
}

output "vnet_names" {
  description = "Map of virtual network names."
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.name }
}

output "subnet_ids" {
  description = "Map of subnet IDs (key = vnet_key-subnet_key)."
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "pe_subnet_ids" {
  description = "Map of private endpoint subnet IDs per vnet."
  value       = { for k, v in azurerm_subnet.pe_subnet : k => v.id }
}

output "subnet_id_by_name" {
  description = "Lookup subnet ID by vnet name and subnet name."
  value = {
    for k, v in azurerm_subnet.subnet : "${azurerm_virtual_network.vnet[local.all_subnets[k].vnet_key].name}/${v.name}" => v.id
  }
}
