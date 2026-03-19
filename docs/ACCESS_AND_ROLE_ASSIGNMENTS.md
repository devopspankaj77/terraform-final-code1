# Access and Role Assignment Guide

This document provides **step-by-step instructions** for granting users or groups access to each resource type in this project and for **how users actually access** those resources. Use it to onboard new users, create role assignments via Terraform or Azure Portal/CLI, and connect to resources.

---

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Storage Account](#2-storage-account)
3. [Key Vault](#3-key-vault)
4. [SQL Server (Azure SQL)](#4-sql-server-azure-sql)
5. [MySQL Flexible Server](#5-mysql-flexible-server)
6. [Linux Virtual Machine](#6-linux-virtual-machine)
7. [Windows Virtual Machine](#7-windows-virtual-machine)
8. [Resource Group](#8-resource-group)
9. [App Service / Web App](#9-app-service--web-app)
10. [Function App](#10-function-app)
11. [Logic App](#11-logic-app)
12. [API Management](#12-api-management)
13. [Azure Kubernetes Service (AKS)](#13-azure-kubernetes-service-aks)
14. [Redis Cache](#14-redis-cache)
15. [Container Registry (ACR)](#15-container-registry-acr)
16. [Recovery Services Vault](#16-recovery-services-vault)
17. [Log Analytics Workspace](#17-log-analytics-workspace)
18. [Application Insights](#18-application-insights)
19. [Azure Bastion](#19-azure-bastion)
20. [Virtual Network and subnets](#20-virtual-network-and-subnets)

---

## 1. Prerequisites

### 1.1 Get the user or group Object ID (Entra ID)

Role assignments require the **Entra ID (Azure AD) Object ID** of the user or group.

**Option A – Azure Portal**

1. Sign in to [Azure Portal](https://portal.azure.com).
2. Go to **Microsoft Entra ID** (or **Azure Active Directory**).
3. For a **user**: **Identity** → **Users** → select the user → copy **Object ID**.
4. For a **group**: **Identity** → **Groups** → select the group → copy **Object ID**.

**Option B – Azure CLI**

```bash
# User (by UPN)
az ad user show --id "user@yourdomain.com" --query id -o tsv

# Group (by display name)
az ad group show --group "Your Group Name" --query id -o tsv
```

Save this **Object ID** (GUID); you will use it as `principal_id` in Terraform or in Azure role assignments.

### 1.2 Who can create role assignments?

- To **add entries to `role_assignments` in Terraform**, the identity running `terraform apply` must have **User Access Administrator** or **Owner** on the subscription or the resource group.
- To **assign roles in Azure Portal or CLI**, you need the same permissions (User Access Administrator or Owner).

### 1.3 Terraform role assignment block (shared structure)

For resources that support the root **`role_assignments`** variable (Storage, Key Vault, SQL Server, Linux VM, Windows VM, Resource Group), use this structure in `environments/dev/dev.tfvars` (or your environment’s tfvars):

```hcl
role_assignments = {
  unique_key = {
    scope_type           = "resource_type"   # see each section below
    scope_key            = "main"            # or "sample" etc. – logical key in tfvars
    role_definition_name = "Azure Role Name"
    principal_id         = "<object-id-guid>"
    principal_type       = "User"            # or "Group", "ServicePrincipal"
    description          = "Short description"
  }
}
```

After editing tfvars, run `terraform plan` and `terraform apply` to create the assignment.

---

## 2. Storage Account

**What access means:** List/read/write blobs, queues, tables, or files via Azure tools/APIs using Entra ID (no storage key).

### 2.1 Recommended roles

| Role | Use case |
|------|----------|
| **Storage Blob Data Reader** | Read blobs only |
| **Storage Blob Data Contributor** | Read + write + delete blobs |
| **Storage Queue Data Reader** | Read queues |
| **Storage Queue Data Contributor** | Read + write queues |
| **Storage Table Data Reader** | Read tables |
| **Storage Table Data Contributor** | Read + write tables |
| **Storage Blob Data Owner** | Full blob access including ACLs |

### 2.2 Assign role via Terraform

In `role_assignments` (e.g. `environments/dev/dev.tfvars`):

```hcl
role_assignments = {
  storage_blob_reader = {
    scope_type           = "storage_account"
    scope_key            = "main"              # matches storage_accounts.main
    role_definition_name = "Storage Blob Data Reader"
    principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    principal_type       = "User"
    description          = "Read blob access for user"
  }
}
```

Use **`scope_key`** = the key of the storage account in your tfvars (e.g. `main`, `logicapp`).

### 2.3 Assign role via Azure Portal

1. Portal → **Storage accounts** → select the account (e.g. `icr002azureintstobankdev`).
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → choose e.g. **Storage Blob Data Reader** or **Storage Blob Data Contributor**.
4. **Members** → **User, group, or service principal** → select the user/group → **Save**.

### 2.4 How the user accesses the storage account

- **Azure Portal:** Storage account → **Containers** / **Queues** / **Tables**; sign in with the same Entra ID account.
- **Azure Storage Explorer:** Sign in with **Azure account** (Entra ID); browse the subscription and storage account.
- **AzCopy:** Use `azcopy login` (Entra ID); then use the storage account URL in commands.
- **Application code:** Use **DefaultAzureCredential** (or similar) and the storage account URL; no key needed if the app runs as a user or managed identity with the same roles.

**Note:** The storage account must allow Entra ID auth (this project uses `shared_access_key_enabled = false` for key-less access where applicable).

---

## 3. Key Vault

**What access means:** Get/list secrets, certificates, or keys (depending on role and access policies).

### 3.1 Recommended roles (RBAC mode)

This project uses **RBAC** for Key Vault (`enable_rbac_authorization = true`). Use Azure roles:

| Role | Use case |
|------|----------|
| **Key Vault Secrets User** | Get secrets (e.g. for apps or users) |
| **Key Vault Secrets Officer** | Create/update/delete secrets |
| **Key Vault Certificates User** | Get certificates |
| **Key Vault Crypto User** | Use keys for encrypt/decrypt/sign |
| **Key Vault Administrator** | Full Key Vault management |

### 3.2 Assign role via Terraform

```hcl
kv_secrets_user = {
  scope_type           = "key_vault"
  scope_key            = "main"              # matches key_vaults.main
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  principal_type       = "User"
  description          = "Read secrets for user"
}
```

### 3.3 Assign role via Azure Portal

1. Portal → **Key vaults** → select the vault (e.g. `ICR-002-INT-KV-BankDev`).
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → **Key Vault Secrets User** (or other role above).
4. **Members** → select user/group → **Save**.

### 3.4 How the user accesses Key Vault

- **Azure Portal:** Key Vault → **Secrets** / **Certificates** / **Keys**; sign in with Entra ID.
- **Azure CLI:** `az login` then e.g. `az keyvault secret show --vault-name <vault-name> --name <secret-name>`.
- **Application:** Use **DefaultAzureCredential** and the Key Vault URI (e.g. `https://<vault-name>.vault.azure.net/`).

---

## 4. SQL Server (Azure SQL)

**What access means:** Connect to Azure SQL databases using Entra ID (no SQL login/password).

### 4.1 Prerequisites on the server

- An **Azure AD administrator** must be set on the SQL server (user or group). This is often configured in Terraform via `azuread_administrator` in `sql_servers`.
- For **Entra-only** auth, set `azuread_authentication_only = true` and omit SQL login/password in tfvars.

### 4.2 Recommended roles

| Role | Scope | Use case |
|------|--------|----------|
| **SQL DB Contributor** | Database or server | Create/alter databases; manage data and schema |
| **SQL Server Contributor** | Server | Manage server (not data) |
| **Directory Readers** (Entra ID) | Tenant | Required for some users/groups to be recognized as SQL AD admin or for login |

For **database-level** access, assign **SQL DB Contributor** or custom roles at the **database** scope (see Portal/CLI below).

### 4.3 Assign role via Terraform (server scope)

```hcl
sql_db_contributor = {
  scope_type           = "sql_server"
  scope_key            = "main"              # matches sql_servers.main
  role_definition_name = "SQL DB Contributor"
  principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  principal_type       = "User"
  description          = "Database access for user"
}
```

This assigns at **SQL server** scope. For database-level roles, use Portal or CLI.

### 4.4 Assign role via Azure Portal

1. **Server-level:** SQL server resource → **Access control (IAM)** → Add role assignment (e.g. **SQL DB Contributor**).
2. **Database-level:** SQL server → **Databases** → select database → **Access control (IAM)** → Add role assignment.

### 4.5 How the user connects to SQL

- **SSMS / Azure Data Studio:**  
  - Server: `<server-name>.database.windows.net`.  
  - Authentication: **Azure Active Directory - Universal with MFA** (or **Azure Active Directory - Password**).  
  - Sign in with the Entra ID account that has been granted access.
- **Connection string:** Use `Authentication=Active Directory Default` (or similar) and no SQL password; the app must run in a context that has the same Entra ID identity (user or managed identity) with the right role.

---

## 5. MySQL Flexible Server

**What access means:** Connect to MySQL using Entra ID (Azure AD authentication).

### 5.1 Prerequisites on the server

- **Azure AD admin** must be configured on the MySQL Flexible Server (via Portal or API). Terraform may create the server; admin is often set separately.
- User or group must be added as **Azure AD administrator** for the server, or use a MySQL user that maps to Entra ID.

### 5.2 Assign access (Azure Portal / CLI)

Terraform `role_assignments` in this project do **not** include MySQL. Use one of:

**Option A – Azure Portal**

1. **MySQL Flexible Server** → **Settings** → **Azure AD admin** (or **Authentication**) → **Add admin** → select user or group.

**Option B – Azure CLI**

```bash
# Assign the built-in role for MySQL (if available in your tenant)
az role assignment create \
  --role "MySQL Flexible Server User" \
  --assignee-object-id "<user-or-group-object-id>" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.DBforMySQL/flexibleServers/<server-name>"
```

(Exact role name may vary; check **Access control (IAM)** on the MySQL server for available roles.)

### 5.3 How the user connects

- **MySQL client (e.g. mysql, MySQL Workbench):** Use Azure AD authentication (e.g. `mysql -h <server>.mysql.database.azure.com -u <user@domain> -p --enable-cleartext-plugin` and sign in with Entra ID when prompted, or use a token).
- **Application:** Use a connector that supports Azure AD auth and **DefaultAzureCredential** (or client secret for service principals).

---

## 6. Linux Virtual Machine

**What access means:** SSH into the VM using Entra ID (Azure AD login extension).

### 6.1 Recommended role

| Role | Use case |
|------|----------|
| **Virtual Machine Administrator Login** | Full sudo access via SSH with Entra ID |
| **Virtual Machine User Login** | Non-admin SSH login with Entra ID |

### 6.2 Assign role via Terraform

```hcl
linux_vm_admin = {
  scope_type           = "linux_vm"
  scope_key            = "sample"             # matches vms.sample in tfvars
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  principal_type       = "User"
  description          = "SSH login to Linux VM via Entra ID"
}
```

### 6.3 Assign role via Azure Portal

1. Open the **Linux VM** resource.
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → **Virtual Machine Administrator Login** (or User Login).
4. **Members** → select user/group → **Save**.

### 6.4 How the user connects (SSH with Entra ID)

1. Ensure **Azure AD login** extension is enabled on the VM (this project enables it by default where configured).
2. Install **Azure CLI** and run `az login`.
3. Get the VM’s private IP (or use Bastion) from the Portal or Terraform outputs.
4. SSH using Azure AD:

   ```bash
   ssh -o CertificateFile=~/.ssh/azure_ad_cert_<user>@<vm-private-ip>
   ```
   Or use:

   ```bash
   az ssh vm -n <vm-name> -g <resource-group>
   ```

5. When prompted, complete the Entra ID sign-in (browser or device code).

---

## 7. Windows Virtual Machine

**What access means:** RDP into the VM using Entra ID (Azure AD login).

### 7.1 Recommended role

| Role | Use case |
|------|----------|
| **Virtual Machine Administrator Login** | Local admin RDP with Entra ID |
| **Virtual Machine User Login** | Non-admin RDP with Entra ID |

### 7.2 Assign role via Terraform

```hcl
windows_vm_admin = {
  scope_type           = "windows_vm"
  scope_key            = "sample"             # matches windows_vms.sample
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  principal_type       = "User"
  description          = "RDP login to Windows VM via Entra ID"
}
```

### 7.3 Assign role via Azure Portal

1. Open the **Windows VM** resource.
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → **Virtual Machine Administrator Login** (or User Login).
4. **Members** → select user/group → **Save**.

### 7.4 How the user connects (RDP with Entra ID)

1. Ensure the VM has **Azure AD login** enabled (this project configures it where used).
2. **Option A – Bastion:**  
   - Portal → **Bastion** → select the VM → **Connect** → **RDP** → sign in with Entra ID.
3. **Option B – RDP client:**  
   - Get the VM’s private IP (or public if exposed).  
   - In **Remote Desktop Connection**, use the IP and sign in with: `AzureAD\<user@domain.com>` and your Entra ID password (or use Windows 10/11 “Sign in with Azure AD” flow).

---

## 8. Resource Group

**What access means:** View or manage all resources in the resource group (depending on role).

### 8.1 Recommended roles

| Role | Use case |
|------|----------|
| **Reader** | View all resources in the RG |
| **Contributor** | Create/change/delete resources (no IAM) |
| **Owner** | Full access including IAM |

### 8.2 Assign role via Terraform

```hcl
rg_reader = {
  scope_type           = "resource_group"
  scope_key            = "main"               # matches resource_groups.main
  role_definition_name = "Reader"
  principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  principal_type       = "User"
  description          = "Read access to resource group"
}
```

### 8.3 Assign role via Azure Portal

1. Open the **Resource group** (e.g. `ICR-002-Azure-INT-RG-Bank-Dev`).
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → **Reader** (or Contributor/Owner).
4. **Members** → select user/group → **Save**.

### 8.4 How the user accesses

- **Azure Portal:** After signing in, the user sees the resource group and all resources they have access to (depending on role and any resource-level assignments).

---

## 9. App Service / Web App

**What access means:** View or manage the Web App (deploy, change settings, view logs). Application-level access is via the app’s URL and auth (e.g. anonymous or app-level login).

### 9.1 Recommended roles

| Role | Use case |
|------|----------|
| **Website Contributor** | Deploy and manage the web app (no IAM) |
| **Reader** | View app and basic properties |

### 9.2 Assign role (Portal or CLI)

Terraform `role_assignments` does not include App Service in this project. Use Portal or CLI:

1. Portal → **App Service** (Web App) → **Access control (IAM)** → **Add role assignment**.
2. **Role** → **Website Contributor** or **Reader**.
3. **Members** → select user/group → **Save**.

**CLI example:**

```bash
az role assignment create \
  --role "Website Contributor" \
  --assignee-object-id "<object-id>" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app-name>"
```

### 9.3 How the user accesses

- **Manage:** Portal → **App Services** → select the app; or use VS Code Azure App Service extension, or Azure CLI.
- **Use the app:** Open the app URL (e.g. `https://<app-name>.azurewebsites.net`) in a browser; auth depends on app configuration (e.g. anonymous or Entra ID login).

---

## 10. Function App

**What access means:** Manage the Function App (deploy, view logs, manage functions). Runtime access is via HTTP triggers and the app’s managed identity / storage access.

### 10.1 Recommended roles

| Role | Use case |
|------|----------|
| **Website Contributor** | Deploy and manage the Function App |
| **Reader** | View app and monitor |

### 10.2 Assign role (Portal or CLI)

1. Portal → **Function App** → **Access control (IAM)** → **Add role assignment**.
2. **Role** → **Website Contributor** or **Reader**.
3. **Members** → select user/group → **Save**.

### 10.3 How the user accesses

- **Manage:** Portal → **Function Apps** → select the app; or VS Code Azure Functions extension; or Azure CLI.
- **Invoke:** Call the function HTTP trigger URL (from Portal or Key Vault/App Configuration if stored). The app uses its managed identity for storage; no user role on storage is required for normal invocation.

---

## 11. Logic App

**What access means:** View and manage the Logic App (edit workflows, view runs, enable/disable).

### 11.2 Recommended roles

| Role | Use case |
|------|----------|
| **Logic App Contributor** | Edit and manage the Logic App |
| **Reader** | View app and run history |

### 11.2 Assign role (Portal or CLI)

1. Portal → **Logic App** (workflow) → **Access control (IAM)** → **Add role assignment**.
2. **Role** → **Logic App Contributor** or **Reader**.
3. **Members** → select user/group → **Save**.

### 11.3 How the user accesses

- **Manage:** Portal → **Logic Apps** → select the app → **Designer** / **Runs**.
- **Trigger:** Logic Apps are usually triggered by events, HTTP, or schedules; no direct “user login” to the app.

---

## 12. API Management

**What access means:** Use the developer portal, call APIs, or manage APIM (APIs, products, subscriptions).

### 12.1 Recommended roles

| Role | Use case |
|------|----------|
| **API Management Service Contributor** | Full APIM management |
| **API Management Service Reader** | Read-only APIM access |
| **Developer** (APIM built-in) | Use developer portal and call APIs (assigned at APIM level or product level) |

### 12.2 Assign role (Portal or CLI)

1. Portal → **API Management service** → **Access control (IAM)** → **Add role assignment**.
2. For **management:** Role → **API Management Service Contributor** or **Reader**.
3. For **developer access:** Use APIM’s **Users** and **Groups** and assign to **Products** or give a **Subscription** key; or use APIM’s identity/Entra integration.

### 12.3 How the user accesses

- **Manage:** Portal → **API Management** → select the instance.
- **Call APIs:** Use the **Developer portal** URL (if enabled) or the API base URL + subscription key / OAuth as configured in APIM.

---

## 13. Azure Kubernetes Service (AKS)

**What access means:** Run `kubectl` and manage the cluster (or only view), depending on Azure RBAC and AKS integration.

### 13.1 Recommended roles (Azure RBAC for AKS)

| Role | Use case |
|------|----------|
| **Azure Kubernetes Service Cluster Admin Role** | Full cluster admin via `kubectl` |
| **Azure Kubernetes Service Cluster User Role** | Get credentials and access cluster (cluster role decides what they can do inside) |
| **Reader** | View AKS resource only |

### 13.2 Assign role (Portal or CLI)

1. Portal → **Kubernetes service** (AKS cluster) → **Access control (IAM)**.
2. **Add** → **Add role assignment** → **Role** → **Azure Kubernetes Service Cluster User Role** (or Admin Role).
3. **Members** → select user/group → **Save**.

**CLI:**

```bash
az role assignment create \
  --role "Azure Kubernetes Service Cluster User Role" \
  --assignee-object-id "<object-id>" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<cluster-name>"
```

### 13.3 How the user accesses

1. **Get credentials:**  
   `az aks get-credentials --resource-group <rg> --name <cluster-name>`
2. **Use kubectl:**  
   `kubectl get nodes` (and other commands). Entra ID is used for authentication; in-cluster RBAC (e.g. role/clusterrole bindings) controls what they can do inside the cluster.

---

## 14. Redis Cache

**What access means:** View the Redis resource and get connection details; application access uses connection string or Entra ID (if supported).

### 14.1 Recommended roles

| Role | Use case |
|------|----------|
| **Reader** | View Redis and connection info (e.g. host name); use access keys from Key Vault or elsewhere |
| **Redis Cache Contributor** | Manage Redis (scale, settings) |

### 14.2 Assign role (Portal or CLI)

1. Portal → **Azure Cache for Redis** → **Access control (IAM)** → **Add role assignment**.
2. **Role** → **Reader** or **Redis Cache Contributor**.
3. **Members** → select user/group → **Save**.

### 14.3 How the user accesses

- **Manage:** Portal → **Azure Cache for Redis** → select the instance; **Connection strings** (if keys are enabled) or **Access keys** (with Contributor or custom key access).
- **Application:** Use connection string (host, port, access key) or Entra ID if the Redis instance and client support it.

---

## 15. Container Registry (ACR)

**What access means:** Pull/push images using Entra ID (no admin user password).

### 15.1 Recommended roles

| Role | Use case |
|------|----------|
| **AcrPull** | Pull images only |
| **AcrPush** | Pull and push images |
| **AcrDelete** | Delete repositories/images |

### 15.2 Assign role (Portal or CLI)

1. Portal → **Container registries** → select the ACR → **Access control (IAM)**.
2. **Add** → **Add role assignment** → **Role** → **AcrPull** or **AcrPush**.
3. **Members** → select user/group → **Save**.

**CLI:**

```bash
az role assignment create \
  --role "AcrPull" \
  --assignee-object-id "<object-id>" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/<acr-name>"
```

### 15.3 How the user accesses

- **Docker login (Entra ID):**  
  `az acr login --name <acr-name>` (after `az login`).
- **Pull:**  
  `docker pull <acr-name>.azurecr.io/<image>:<tag>`.

---

## 16. Recovery Services Vault

**What access means:** Restore backups, run backup jobs, or manage the vault.

### 16.1 Recommended roles

| Role | Use case |
|------|----------|
| **Backup Reader** | View backups and backup jobs |
| **Backup Operator** | Run backup/restore (no delete vault) |
| **Backup Contributor** | Full backup management (no IAM) |

### 16.2 Assign role (Portal or CLI)

1. Portal → **Recovery Services vaults** → select the vault → **Access control (IAM)**.
2. **Add** → **Add role assignment** → **Role** → **Backup Reader** / **Backup Operator** / **Backup Contributor**.
3. **Members** → select user/group → **Save**.

### 16.3 How the user accesses

- **Portal:** Recovery Services vault → **Backup items** / **Backup jobs** → **Restore** (if they have operator/contributor).

---

## 17. Log Analytics Workspace

**What access means:** Run queries, view logs, and use workbooks.

### 17.1 Recommended roles

| Role | Use case |
|------|----------|
| **Log Analytics Reader** | Run queries and view data |
| **Log Analytics Contributor** | Run queries, create/edit saved queries, alerts |

### 17.2 Assign role (Portal or CLI)

1. Portal → **Log Analytics workspaces** → select the workspace → **Access control (IAM)**.
2. **Add** → **Add role assignment** → **Role** → **Log Analytics Reader** or **Log Analytics Contributor**.
3. **Members** → select user/group → **Save**.

### 17.3 How the user accesses

- **Portal:** **Monitor** → **Logs** → select the workspace → run KQL queries.
- **Application:** Use Log Analytics REST API or SDK with Entra ID auth (e.g. DefaultAzureCredential).

---

## 18. Application Insights

**What access means:** View telemetry, run queries, and manage components.

### 18.1 Recommended roles

| Role | Use case |
|------|----------|
| **Monitoring Reader** | View metrics and logs |
| **Monitoring Contributor** | Create/edit alerts, modify components |

### 18.2 Assign role (Portal or CLI)

1. Portal → **Application Insights** resource → **Access control (IAM)**.
2. **Add** → **Add role assignment** → **Role** → **Monitoring Reader** or **Monitoring Contributor**.
3. **Members** → select user/group → **Save**.

### 18.3 How the user accesses

- **Portal:** **Monitor** → **Application Insights** → select the resource → **Logs** / **Performance** / **Failures** etc.

---

## 19. Azure Bastion

**What access means:** Use Bastion to open RDP/SSH sessions to VMs without exposing them to the internet.

### 19.1 Prerequisites

- The user still needs **Virtual Machine Administrator Login** (or User Login) on the **target VM** to connect through Bastion.
- **Bastion** itself typically does not require a separate role for “use Bastion”; access is controlled by (1) who can see/use the Bastion resource and (2) who has VM login role on the target VM.

### 19.2 Assign access

- **To use Bastion:** Grant **Reader** on the Bastion resource (or on the resource group) so the user can open the Bastion blade and click Connect.
- **To connect to a VM:** Assign **Virtual Machine Administrator Login** (or User Login) on the **VM** (see [Windows VM](#7-windows-virtual-machine) and [Linux VM](#6-linux-virtual-machine)).

### 19.3 How the user accesses

1. Portal → **Bastion** (or VM → **Connect** → **Bastion**).
2. Enter VM credentials: for RDP/SSH with Entra ID, use **Azure AD** sign-in when prompted.
3. Session opens in the browser.

---

## 20. Virtual Network and subnets

**What access means:** View or modify VNet, subnets, NSGs, and private endpoints.

### 20.1 Recommended roles

| Role | Use case |
|------|----------|
| **Reader** | View VNet, subnets, NSGs |
| **Network Contributor** | Create/change/delete networks, subnets, NSGs, peerings |

### 20.2 Assign role (Portal or CLI)

1. Portal → **Virtual networks** → select the VNet (or **Resource group** for broader access).
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. **Role** → **Reader** or **Network Contributor**.
4. **Members** → select user/group → **Save**.

### 20.3 How the user accesses

- **Portal:** **Virtual networks** → select the VNet → **Subnets** / **Settings** / **Networking**.
- **CLI:** `az network vnet show` etc., after `az login`.

---

## Quick reference: Terraform scope_type and scope_key

| scope_type     | scope_key example | Matches in tfvars                    |
|----------------|-------------------|--------------------------------------|
| resource_group | main              | resource_groups.main                 |
| storage_account| main, logicapp    | storage_accounts.main, .logicapp     |
| key_vault      | main              | key_vaults.main                      |
| sql_server     | main              | sql_servers.main                     |
| linux_vm       | sample            | vms.sample                           |
| windows_vm     | sample            | windows_vms.sample                   |

---

## Summary checklist for a new user

1. **Get Object ID** (user or group) from Entra ID (Portal or `az ad user/group show`).
2. **Choose resource(s)** and **role(s)** from the tables above.
3. **Add Terraform role_assignments** for Storage, Key Vault, SQL Server, Linux VM, Windows VM, or Resource Group (then run `terraform apply`), or **assign roles in Azure Portal/CLI** for any resource.
4. **Ensure Terraform runner** (or the person assigning in Portal) has **User Access Administrator** or **Owner**.
5. **Share with the user:** resource names, URLs (Portal links, app URLs, connection strings where applicable), and that they must sign in with **Entra ID** (and for VMs, use Bastion or RDP/SSH with Azure AD as described above).

For more on Entra ID–first configuration (storage, SQL, VMs), see [ENTRA_ID_ACCESS.md](ENTRA_ID_ACCESS.md).
