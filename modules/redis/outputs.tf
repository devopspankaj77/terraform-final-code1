output "ids" {
  value = { for k, v in azurerm_redis_cache.redis : k => v.id }
}
output "hostnames" {
  value = { for k, v in azurerm_redis_cache.redis : k => v.hostname }
}
output "primary_connection_strings" {
  value     = { for k, v in azurerm_redis_cache.redis : k => v.primary_connection_string }
  sensitive = true
}
