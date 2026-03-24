# Azure RBAC role assignments (users, groups, service principals on resource scope)

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  name                             = try(each.value.assignment_name, null)
  scope                            = each.value.scope_id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = each.value.principal_id
  principal_type = try(each.value.principal_type, null)
  description    = try(each.value.description, null)
}
