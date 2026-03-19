# Customer-Managed Key (CMK) Encryption

Optional **customer-managed key** encryption is supported so you can use keys held in **Azure Key Vault** (and control rotation/revocation) instead of Microsoft-managed keys.

## Storage Account

Storage accounts can use a Key Vault key for encryption.

### 1. Create a key in Key Vault

Create a key in your Key Vault (e.g. via Azure Portal, CLI, or Terraform `azurerm_key_vault_key`). You will need the **Key Vault resource ID** and the **key name** (and optionally the key version for a specific version).

### 2. Grant the storage identity access to the key

The storage account uses either **system-assigned** or **user-assigned** identity to access the key. That identity needs:

- **RBAC:** role **Key Vault Crypto User** on the Key Vault (or on the key), or  
- **Access policy:** Get, Wrap Key, Unwrap Key (if not using RBAC-only).

If you use **system-assigned identity** (default when only `key_vault_id` and `key_name` are set), assign the role/policy to the storage account’s principal after the first apply. If you use **user-assigned identity**, assign the role/policy to that identity.

### 3. Configure in tfvars

In your storage account config, set **`customer_managed_key`**:

```hcl
storage_accounts = {
  main = {
    name                = "icr002azureintstobankdev"
    resource_group_name = "ICR-002-Azure-INT-RG-Bank-Dev"
    location             = "centralindia"
    # ... other settings ...

    # Optional: encrypt with key from Key Vault (CMK)
    customer_managed_key = {
      key_vault_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>"
      key_name     = "storage-cmk-key"
      # key_version = "abc123..."  # optional; omit to use latest
      # user_assigned_identity_id = azurerm_user_assigned_identity.storage.id  # optional; omit to use system-assigned
    }
  }
}
```

- **key_vault_id** (required): Key Vault resource ID.
- **key_name** (required): Name of the key in the vault.
- **key_version** (optional): Key version; omit to use the latest (enables automatic key rotation when you rotate in Key Vault).
- **user_assigned_identity_id** (optional): User-assigned identity for key access. If omitted, the storage account’s **system-assigned** identity is used (ensure that identity has Key Vault Crypto User or equivalent).

### 4. Role assignment for system-assigned identity

After the storage account exists, grant its system-assigned identity access to the key, e.g. via `role_assignments` or a separate `azurerm_role_assignment`:

- **Scope:** the Key Vault (or the key).
- **Role:** **Key Vault Crypto User**.
- **Principal:** storage account’s system-assigned identity (object ID from Azure Portal or `azurerm_storage_account.sa["main"].identity[0].principal_id`).

Alternatively use Key Vault access policies if the vault is not RBAC-only.

---

## Other resources

- **ACR (Container Registry):** The registry module already supports optional `encryption` with `key_vault_key_id` and `identity_client_id` (see `modules/registry`).
- **SQL Server / TDE:** Transparent Data Encryption with customer-managed key can be configured via Azure Portal or separate Key Vault key and TDE configuration; the SQL module can be extended with optional CMK if needed.
- **VM disks:** Server-side encryption with customer-managed key uses a **Disk Encryption Set** (DES) referencing a Key Vault key; this can be added as an optional pattern in the VM modules.
