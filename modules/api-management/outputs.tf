output "ids" {
  value = { for k, v in azurerm_api_management.apim : k => v.id }
}
output "gateway_urls" {
  value = { for k, v in azurerm_api_management.apim : k => v.gateway_url }
}
