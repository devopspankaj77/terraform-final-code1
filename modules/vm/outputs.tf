output "vm_ids" {
  description = "Map of VM IDs."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_private_ips" {
  description = "Map of VM private IP addresses."
  value       = { for k, v in azurerm_network_interface.nic : k => v.private_ip_address }
}

output "vm_public_ips" {
  description = "Map of VM public IPs (only where create_public_ip = true)."
  value       = { for k, v in azurerm_public_ip.pip : k => v.ip_address }
}

output "principal_ids" {
  description = "Map of VM system-assigned managed identity principal IDs."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => try(v.identity[0].principal_id, null) }
}
