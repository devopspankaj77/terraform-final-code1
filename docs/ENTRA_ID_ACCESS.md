# Entra ID (Azure AD) Based Access

Resources are configured for **Entra ID–first** access where possible; **username/password (or shared keys) are optional** for legacy or break-glass use.

## Summary

| Resource | Entra ID / preferred auth | Username / password or key |
|----------|---------------------------|-----------------------------|
| **Storage Account** | RBAC (no shared key) | Optional: set `shared_access_key_enabled = true` when needed |
| **SQL Server** | Azure AD admin + `azuread_authentication_only = true` | Optional: set `administrator_login` / `administrator_login_password` when SQL auth needed |
| **MySQL Flexible Server** | Entra ID auth (configure AAD admin and `aad_auth_only` as needed) | Optional: omit `administrator_login` / `administrator_password`; placeholder used at create when both null |
| **Windows VM** | Azure AD login extension (preferred) | Optional: omit `admin_password`; generated placeholder used when null |
| **Linux VM** | Azure AD login extension; SSH key | `admin_password` already optional when `disable_password_authentication = true` |

## SQL Server – Entra ID only

- Set **`azuread_administrator`** with **`azuread_authentication_only = true`** and leave **`administrator_login`** and **`administrator_login_password`** unset (or `null`).
- Provide `login_username` (e.g. group name) and `object_id` (Entra ID object ID of the user/group).
- Example (in tfvars):

```hcl
azuread_administrator = {
  login_username              = "My SQL Admins"
  object_id                   = "<entra-group-or-user-object-id>"
  azuread_authentication_only = true
}
# administrator_login = null
# administrator_login_password = null
```

## MySQL Flexible Server – Entra ID first

- Omit **`administrator_login`** and **`administrator_password`** (or set to `null`) to use Entra ID–first; the module uses a generated placeholder at create so Azure API requirements are met. Configure Entra admin and, if desired, `aad_auth_only` via Azure/API after create.
- When using MySQL native auth, set both `administrator_login` and `administrator_password` (e.g. via TF_VAR or Key Vault).

## Windows VM – Entra ID login

- Prefer **Azure AD login** (extension is enabled by default). You can omit **`admin_password`**; the module generates a placeholder for VM create. Use Entra ID for sign-in and treat local admin as break-glass only.
- When you need a known local password, set `admin_password` (e.g. via TF_VAR or Key Vault).

## Storage Account

- Default is **no shared key** (`shared_access_key_enabled = false`). Use **RBAC** (and, for Function/Logic Apps, managed identity + role assignments).
- Set **`shared_access_key_enabled = true`** only when key-based access is required.

---

## Optional: Role assignments for user/group access

Use **`role_assignments`** in tfvars to grant specific users or groups access to any of the deployed resources. Each entry needs:

- **`scope_type`**: `resource_group` | `storage_account` | `key_vault` | `sql_server` | `linux_vm` | `windows_vm`
- **`scope_key`**: logical name of the resource (e.g. `main`, `sample`) as in your tfvars (e.g. `storage_accounts.main`, `vms.sample`).
- **`role_definition_name`**: Azure built-in role, e.g. `Storage Blob Data Reader`, `Key Vault Secrets User`, `Virtual Machine Administrator Login`, `SQL DB Contributor`, `Reader`.
- **`principal_id`**: Entra ID object ID of the user, group, or service principal (from Azure Portal > Microsoft Entra ID > Users or Groups).
- **`principal_type`** (optional): `User`, `Group`, or `ServicePrincipal`.
- **`description`** (optional): short note for the assignment.

Example (in tfvars):

```hcl
role_assignments = {
  storage_reader = {
    scope_type           = "storage_account"
    scope_key            = "main"
    role_definition_name = "Storage Blob Data Reader"
    principal_id         = "<user-or-group-object-id>"
    principal_type       = "User"
    description          = "Read blob access for user"
  }
  windows_vm_admin = {
    scope_type           = "windows_vm"
    scope_key            = "sample"
    role_definition_name = "Virtual Machine Administrator Login"
    principal_id         = "<user-or-group-object-id>"
    description          = "RDP login via Entra ID"
  }
}
```

See **environments/dev/dev.tfvars** for more commented examples (storage, Key Vault, SQL, Linux/Windows VM login, resource group Reader).
