# =============================================================================
# Virtual Machine (Linux) - Enterprise Module
# Security: SSH keys, AAD login, managed identity, boot diag, encryption at host
# =============================================================================

# Public IP only when explicitly required (e.g. jump box)
resource "azurerm_public_ip" "pip" {
  for_each = { for k, v in var.vms : k => v if try(v.create_public_ip, false) }

  name                = "${each.value.name}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = try(each.value.availability_zone, null) != null ? [each.value.availability_zone] : null
  tags                = merge(var.common_tags, each.value.tags)
}

resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.value.name}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  accelerated_networking_enabled = try(each.value.accelerated_networking, false)
  tags                = merge(var.common_tags, each.value.tags)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(var.vms[each.key].create_public_ip, false) ? azurerm_public_ip.pip[each.key].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  admin_password                  = try(each.value.disable_password_authentication, true) ? null : each.value.admin_password
  disable_password_authentication = coalesce(each.value.disable_password_authentication, true)
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  computer_name                   = coalesce(try(each.value.computer_name, null), substr(replace(each.value.name, "-", ""), 0, 64))
  custom_data                     = try(each.value.custom_data, null) != null ? base64encode(each.value.custom_data) : null

  zone = try(each.value.availability_zone, null)
  availability_set_id = try(each.value.availability_set_id, null)

  # Default false: Microsoft.Compute/EncryptionAtHost must be enabled in subscription
  encryption_at_host_enabled = try(each.value.encryption_at_host_enabled, false)
  secure_boot_enabled       = try(each.value.secure_boot_enabled, true)
  vtpm_enabled              = try(each.value.vtpm_enabled, true)

  dynamic "admin_ssh_key" {
    for_each = coalesce(each.value.admin_ssh_key, [])
    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key
    }
  }

  os_disk {
    name                 = "${each.value.name}-osdisk"
    caching              = try(each.value.os_disk.caching, "ReadWrite")
    storage_account_type = try(each.value.os_disk.storage_account_type, "Premium_LRS")
    disk_size_gb         = try(each.value.os_disk.disk_size_gb, null)
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = try(each.value.source_image_reference.version, "latest")
  }

  boot_diagnostics {
    storage_account_uri = try(each.value.boot_diagnostics.storage_account_uri, null)
  }

  identity {
    type         = try(each.value.identity_type, "SystemAssigned")
    identity_ids = try(each.value.identity_type, "SystemAssigned") == "UserAssigned" || try(each.value.identity_type, "SystemAssigned") == "SystemAssigned,UserAssigned" ? each.value.identity_ids : null
  }

  tags = merge(var.common_tags, each.value.tags)

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

# Azure AD login extension (assign "Virtual Machine Administrator Login" role to users)
resource "azurerm_virtual_machine_extension" "aad_login" {
  for_each = { for k, v in var.vms : k => v if try(v.enable_aad_login_extension, true) }

  name                 = "AADSSHLoginForLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
  tags                 = merge(var.common_tags, each.value.tags)
}
