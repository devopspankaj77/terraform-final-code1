output "ids" {
  value = { for k, v in azurerm_bastion_host.bastion : k => v.id }
}
output "dns_names" {
  value = { for k, v in azurerm_bastion_host.bastion : k => v.dns_name }
}
