# =============================================================================
# App Service Plan + Windows/Linux Web App - Enterprise Module Variables
# Spec: name, resource_group_name, location, plan_sku (required); https_only, ftps_state (optional)
# =============================================================================

variable "app_service_plans" {
  description = "Map of App Service Plan configurations. Keys are logical names."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    os_type             = string # Windows, Linux
    sku_name            = string # B1, B2, B3, P1v2, P2v2, P3v2, S1, etc.

    tags = optional(map(string), {})
  }))
}

variable "web_apps" {
  description = "Map of Web App configurations; use app_service_plan_key (e.g. 'main') to reference a plan in this module, or app_service_plan_id for external plan."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    app_service_plan_id = optional(string) # Omit when using app_service_plan_key
    app_service_plan_key = optional(string) # Key into app_service_plans (e.g. 'main'); resolved to plan ID in module

    os_type = optional(string, "Linux") # Linux, Windows

    https_only          = optional(bool, true)
    ftps_state          = optional(string, "Disabled")
    minimum_tls_version = optional(string, "1.2")
    always_on           = optional(bool, true)

    app_settings = optional(map(string), {})
    connection_string = optional(list(object({
      name  = string
      type  = string
      value = string
    })), [])

    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
