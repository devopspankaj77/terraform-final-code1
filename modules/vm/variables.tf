# =============================================================================
# Virtual Machine (Linux) - Enterprise Module Variables
# Spec: vm_name, vm_size, admin_username, public_key (or admin_password), subnet_id, os_disk_type, source_image_* (required)
# Naming: ICR-<nnn>-Azure-LIN-<INT|CLT>-<Workload>
# =============================================================================

variable "vms" {
  description = "Map of Linux VM configurations. Keys are logical names."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string
    size                = string
    subnet_id           = string
    admin_username     = string

    # Optional - Auth (prefer SSH key; password for fallback only)
    admin_password                  = optional(string) # sensitive; use TF_VAR or KV
    disable_password_authentication = optional(bool, true)
    admin_ssh_key = optional(list(object({
      username   = string
      public_key = string
    })), [])

    # Optional - Network
    create_public_ip     = optional(bool, false) # false for security; true only for jump
    private_ip_address   = optional(string)
    nsg_id               = optional(string)
    accelerated_networking = optional(bool, false)

    # Optional - OS disk (security: use Premium, encryption)
    os_disk = optional(object({
      caching                   = optional(string, "ReadWrite")
      storage_account_type      = optional(string, "Premium_LRS")
      disk_size_gb              = optional(number)
      write_accelerator_enabled = optional(bool, false)
    }), { caching = "ReadWrite", storage_account_type = "Premium_LRS" })

    # Optional - Source image
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    }), { publisher = "Canonical", offer = "0001-com-ubuntu-server-jammy", sku = "22_04-lts", version = "latest" })

    # Optional - Security baseline
    encryption_at_host_enabled = optional(bool, true)
    secure_boot_enabled        = optional(bool, true)
    vtpm_enabled               = optional(bool, true)
    boot_diagnostics = optional(object({
      storage_account_uri = optional(string) # null = use managed; or SA blob endpoint
    }), {})

    # Optional - Identity
    identity_type = optional(string, "SystemAssigned") # SystemAssigned, UserAssigned, or both
    identity_ids  = optional(list(string), [])

    # Optional - Availability
    availability_zone = optional(string) # "1", "2", "3"
    availability_set_id = optional(string)

    # Optional - Extensions (AAD login for SSH)
    enable_aad_login_extension = optional(bool, true)
    custom_data                = optional(string)

    # Optional - Naming
    computer_name = optional(string) # defaults to name if null

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each VM's tags."
  type        = map(string)
  default     = {}
}
