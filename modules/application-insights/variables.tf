# =============================================================================
# Application Insights - Enterprise Module Variables
# Spec: name, resource_group_name, location (required); workspace_id, application_type (optional)
# =============================================================================

variable "app_insights" {
  description = "Map of Application Insights configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string

    application_type    = optional(string, "web")
    workspace_id        = optional(string)
    retention_in_days   = optional(number, 90)
    sampling_percentage = optional(number)

    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
