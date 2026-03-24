output "role_assignment_ids" {
  description = "Map of role assignment resource IDs (key = same as input map key)."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_principal_ids" {
  description = "Map of principal_id per assignment (echo from created resources)."
  value       = { for k, v in azurerm_role_assignment.this : k => v.principal_id }
}
