# =============================================================================
# Dev - Locals: naming and tags (data.azurerm_client_config.current used for subscription context)
# =============================================================================

locals {
  mandatory_tags = {
    "Created By"       = var.created_by
    "Created Date"    = coalesce(var.created_date, formatdate("YYYY-MM-DD", timestamp()))
    "Environment"      = var.environment
    "Requester"        = var.requester
    "Ticket Reference" = var.ticket_reference
    "Project Name"     = var.project_name
    "Subscription Id"  = data.azurerm_client_config.current.subscription_id
  }
  common_tags = merge(local.mandatory_tags, var.additional_tags)
}
