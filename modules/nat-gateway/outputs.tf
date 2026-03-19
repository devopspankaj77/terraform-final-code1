output "ids" {
  value = { for k, v in azurerm_nat_gateway.ngw : k => v.id }
}
