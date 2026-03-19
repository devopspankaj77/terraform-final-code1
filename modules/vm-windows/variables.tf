# =============================================================================
# Virtual Machine (Windows) - Enterprise Module Variables
# Spec: vm_name, vm_size, admin_username, subnet_id, os_disk_type, source_image_* (required); admin_password optional when using Entra ID (AAD) login.
# Naming: ICR-<nnn>-Azure-WIN-<INT|CLT>-<Workload>
# =============================================================================

variable "vms" {
  description = "Map of Windows VM configurations."
  type = map(object({
    # Required
    name                = string
    resource_group_name = string
    location            = string
    size                = string
    subnet_id           = string
    admin_username      = string
    admin_password      = optional(string, null) # optional when using Entra ID login; use TF_VAR or Key Vault when set

    # Optional - Network
    create_public_ip       = optional(bool, false) # false for security; true only for jump
    private_ip_address      = optional(string)
    nsg_id                 = optional(string)
    accelerated_networking = optional(bool, false)

    # Optional - OS disk
    os_disk = optional(object({
      name                 = optional(string)
      caching              = optional(string, "ReadWrite")
      storage_account_type = optional(string, "Premium_LRS")
      disk_size_gb         = optional(number)
      write_accelerator_enabled = optional(bool, false)
    }), { caching = "ReadWrite", storage_account_type = "Premium_LRS" })

    # Optional - Source image
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    }), { publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2022-datacenter-azure-edition", version = "latest" })

    # Optional - Security baseline
    encryption_at_host_enabled = optional(bool, true)
    secure_boot_enabled       = optional(bool, true)
    vtpm_enabled              = optional(bool, true)
    boot_diagnostics = optional(object({
      storage_account_uri = optional(string)
    }), {})

    # Optional - Identity
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])

    # Optional - Availability
    availability_zone   = optional(string)
    availability_set_id = optional(string)

    # Optional - Windows config
    enable_automatic_updates = optional(bool, true)
    patch_mode               = optional(string, "AutomaticByOS") # AutomaticByOS, AutomaticByPlatform, Manual
    hotpatching_enabled      = optional(bool, false)
    timezone                 = optional(string, "UTC")
    license_type             = optional(string, "None") # None, Windows_Client, Windows_Server

    # Optional - WinRM (for automation)
    winrm_listeners = optional(list(object({
      protocol        = string       # Http, Https
      certificate_url = optional(string)
    })), [])

    # Optional - Extensions (AAD login for RDP)
    enable_aad_login_extension = optional(bool, true)
    custom_data                = optional(string)

    # Optional - Naming
    computer_name = optional(string)

    # Optional - Tagging
    tags = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Common tags merged with each VM's tags."
  type        = map(string)
  default     = {}
}
