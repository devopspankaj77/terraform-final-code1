# Security Baseline Status by Module (Detailed)

This document lists the **security baseline status** for each Terraform module in this repository. Format: **Resource** | **Pillar** | **Type** | **Control** | **Prod** | **Non-Prod** | **Reason** | **Implemented** | **Comments**.

**Modules covered (25):** resource-group, vnet, azurerm_public_ip (root: public_ip), vm, vm-windows, storage-account, keyvault, key-vault-secret, sql, private-endpoint, private-dns-zone, bastion, app-service, function-app, logic-app, api-management, aks, registry, mysql-flexible, redis, log-analytics, application-insights, recovery-services-vault, user-assigned-identity, nat-gateway.

**Full control list (CONTROL ID | CONTROL FAMILY | CONTROL NAME | MODULE | STATUS):** see **[SECURITY_BASELINE_CONTROLS_FULL.md](SECURITY_BASELINE_CONTROLS_FULL.md)** for 90+ controls in that format.

---

## resource-group (`modules/resource-group`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Resource Group | Governance | Mandatory | Naming convention (e.g. ICR-&lt;nnn&gt;-Azure-&lt;INT\|CLT&gt;-RG-&lt;Workload&gt;; see docs/NAMING_CONVENTION.md) | Required | Required | Consistency, cost tracking | Yes | Env tfvars: name_prefix, project_type, workload; RG name in tfvars |
| Resource Group | Governance | Mandatory | Mandatory tags (Created By, Created Date, Environment, Requester, Ticket Reference, Project Name, Subscription Id) | Required | Required | Audit, chargeback | Yes | Root main.tf common_tags from tfvars; data.azurerm_client_config for subscription id |
| Resource Group | Governance | Optional | Additional tags (Owner, Cost Center, Data Classification) | Recommended | Optional | FinOps, compliance | Yes | additional_tags in tfvars merged in root |
| Resource Group | Governance | Mandatory | Delete lock (CanNotDelete) | Required | Optional | Prevent accidental deletion | Yes | create_lock, lock_level, lock_name in module; azurerm_management_lock in main.tf |
| Resource Group | Governance | Mandatory | No resources without tags | Required | Required | Enforce via policy | Yes | common_tags passed to all modules from root |
| Resource Group | Cost Optimization | Recommended | Single RG per env/workload | Recommended | Recommended | Clear ownership | Yes | Design: one or more RGs per env in tfvars |
| Resource Group | Operational Excellence | Optional | Document RG purpose in naming or tag | Recommended | Optional | Discoverability | Partial | Add Purpose/Description in additional_tags if needed |

---

## vnet (`modules/vnet`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Virtual Network | Security | Mandatory | NSG on all subnets (except AzureBastionSubnet) | Required | Required | Network segmentation | Yes | create_nsg, nsg_per_subnet; NSG attached via azurerm_subnet_network_security_group_association |
| Virtual Network | Security | Mandatory | NSG on private endpoint subnet when nsg_per_subnet = true | Required | Recommended | Consistent segmentation | Yes | pe_subnet_nsg, pe_subnet_nsg_rule, pe_subnet_nsg_rules; pe_subnet_nsg_rules in tfvars |
| Virtual Network | Security | Mandatory | No 0.0.0.0/0 for management ports (RDP 3389, SSH 22) in production | Required | Required | Limit exposure | Partial | jump_rdp_source_cidr, jump_ssh_source_cidr in root; set via TF_VAR to VPN/bastion CIDR in prod |
| Virtual Network | Security | Mandatory | Private endpoint subnet with network policies disabled | Required | Recommended | PaaS private connectivity | Yes | create_private_endpoint_subnet; pe_subnet has private_endpoint_network_policies = "Disabled" |
| Virtual Network | Security | Mandatory | Deny by default; explicit allow rules only | Required | Required | Least privilege | Yes | nsg_rules are allow-only; no default allow-all |
| Virtual Network | Security | Recommended | Restrict inter-subnet traffic where not needed | Recommended | Recommended | Micro-segmentation | Partial | Define nsg_rules per subnet in tfvars with minimal source/dest CIDRs |
| Virtual Network | Security | Optional | DDoS Protection Standard (optional for critical) | Recommended | Optional | Availability | No | Not in module; enable via portal or separate Terraform |
| Virtual Network | Governance | Mandatory | No overlapping address space across envs | Required | Required | No routing conflicts | Yes | address_space per vnet in tfvars; design per env |
| Virtual Network | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | VNet name and tags from root common_tags |

---

## public_ip / azurerm_public_ip (`modules/azurerm_public_ip`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Public IP | Security | Mandatory | Standard SKU, static allocation | Required | Required | Stable endpoint, no shared SKU | Yes | sku = "Standard", allocation_method in variables |
| Public IP | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | Tags merged in root when calling module (root: module.public_ip) |

---

## vm (`modules/vm` – Linux)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Linux VM | Security | Mandatory | SSH only; disable password authentication in prod | Required | Recommended | Limit exposure | Yes | disable_password_authentication in module; set true in prod tfvars |
| Linux VM | Security | Mandatory | No public IP unless jump box | Required | Optional | Limit exposure | Yes | create_public_ip configurable; default false in samples |
| Linux VM | Security | Mandatory | System-assigned managed identity | Required | Required | Key Vault/storage without secrets | Yes | identity_type, identity_ids in module |
| Linux VM | Security | Recommended | Azure AD login extension | Recommended | Recommended | Identity-based sign-in | Yes | enable_aad_login_extension; assign VM Administrator Login role in AAD |
| Linux VM | Security | Optional | Encryption at host | Recommended | Optional | Confidential computing | Yes | encryption_at_host_enabled in module |
| Linux VM | Security | Optional | Secure Boot, vTPM | Recommended | Optional | Integrity, measured boot | Yes | secure_boot_enabled, vtpm_enabled in module |
| Linux VM | Security | Optional | Boot diagnostics (storage) | Optional | Optional | Troubleshooting | Yes | boot_diagnostics block supported in module |
| Linux VM | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root; computer_name truncated to 64 chars |

---

## vm-windows (`modules/vm-windows`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Windows VM | Security | Mandatory | Strong password policy (Azure enforced) | Required | Required | Credential strength | Yes | admin_password in module; use TF_VAR in prod; optional when Entra ID only |
| Windows VM | Security | Mandatory | No public IP unless jump box | Required | Optional | Limit exposure | Yes | create_public_ip configurable |
| Windows VM | Security | Mandatory | System-assigned managed identity | Required | Required | Key Vault/storage without secrets | Yes | identity_type, identity_ids in module |
| Windows VM | Security | Recommended | Azure AD login extension | Recommended | Recommended | Identity-based sign-in | Yes | enable_aad_login_extension in module |
| Windows VM | Security | Optional | Encryption at host, Secure Boot, vTPM | Recommended | Optional | Confidential computing | Yes | encryption_at_host_enabled, secure_boot_enabled, vtpm_enabled |
| Windows VM | Security | Optional | Automatic updates (patch) | Recommended | Recommended | Patch management | Yes | automatic_updates_enabled in module |
| Windows VM | Security | N/A | OS security baseline (GPO-style) | — | — | Handled by security team | No | Not applied by Terraform; security team sets policies separately. This repo focuses on secured Azure infrastructure only. |
| Windows VM | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags; computer_name max 15 chars in module |

---

## storage-account (`modules/storage-account`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Storage Account | Security | Mandatory | HTTPS only (no HTTP) | Required | Required | Data in transit protection | Yes | https_traffic_only_enabled in module |
| Storage Account | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes | min_tls_version = "TLS1_2" in module |
| Storage Account | Security | Recommended | Entra ID (RBAC) only; shared key disabled | Required | Recommended | No key in config, identity-based access | Yes | shared_access_key_enabled = false in tfvars; use role_assignments for access |
| Storage Account | Security | Optional | Customer-managed key (CMK) encryption | Recommended | Optional | Key control, rotation | Yes | customer_managed_key (key_vault_id, key_name, key_version, user_assigned_identity_id); see docs/CMK_ENCRYPTION.md |
| Storage Account | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled configurable in tfvars |
| Storage Account | Security | Optional | Blob versioning for critical data | Recommended | Optional | Data recovery | Yes | enable_blob_versioning in module variables |
| Storage Account | Security | Optional | Blob/container soft delete retention | Recommended | Optional | Accidental delete recovery | Yes | blob_soft_delete_retention_days, container_soft_delete_retention_days in tfvars |
| Storage Account | Security | Optional | Delete lock | Recommended | Optional | Prevent accidental deletion | Yes | create_delete_lock in storage tfvars where used |
| Storage Account | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root; naming in tfvars (lowercase, no hyphens, 3–24 chars per Azure) |

---

## keyvault (`modules/keyvault`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Key Vault | Security | Mandatory | RBAC only (no access policies) | Required | Required | Least privilege, audit | Yes | rbac_authorization_enabled in module |
| Key Vault | Security | Mandatory | Soft delete enabled | Required | Required | Accidental delete recovery | Yes | soft_delete_retention_days (e.g. 90 in baseline) |
| Key Vault | Security | Mandatory | Purge protection in prod | Required | Optional | Prevent permanent loss | Yes | purge_protection_enabled in tfvars; enable in prod |
| Key Vault | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled configurable |
| Key Vault | Security | Optional | Delete lock | Recommended | Optional | Prevent accidental deletion | Yes | create_delete_lock in keyvault tfvars |
| Key Vault | Security | Optional | Network ACLs (default Deny, bypass AzureServices) | Recommended | Optional | Restrict access | Yes | network_acls block in module |
| Key Vault | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root; name max 24 chars |

---

## key-vault-secret (`modules/key-vault-secret`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Key Vault Secret | Security | Mandatory | Secret value from TF_VAR or Key Vault (no plain text in repo) | Required | Required | No secrets in code | Partial | Module accepts secret_value; supply via TF_VAR_* or KV reference in prod |
| Key Vault Secret | Governance | Optional | Content type for clarity | Optional | Optional | Discoverability | Yes | content_type in module |

---

## sql (`modules/sql`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| SQL Server | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes | minimum_tls_version in module |
| SQL Server | Security | Mandatory | Firewall rules (no 0.0.0.0/0 in prod) | Required | Required | Limit exposure | Yes | firewall_rules in tfvars; restrict to VNet/subnet in prod |
| SQL Server | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled = false in tfvars; private-only via PE/VNet |
| SQL Server | Security | Recommended | Entra ID (Azure AD) administrator; Entra ID–only auth | Required | Recommended | Identity-based auth, no SQL login in config | Yes | azuread_administrator block; azuread_authentication_only = true for Entra-only |
| SQL Server | Security | Optional | Administrator login/password optional when Entra-only | Recommended | Optional | No secrets in repo | Yes | administrator_login, administrator_login_password optional; use TF_VAR when SQL auth used |
| SQL Database | Security | Optional | Short-term retention (backup) | Recommended | Optional | Point-in-time restore | Yes | short_term_retention_days in databases block |
| SQL Server/Database | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root; server name lowercase, hyphens allowed |

---

## private-endpoint (`modules/private-endpoint`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Private Endpoint | Security | Mandatory | Use dedicated PE subnet (network policies disabled) | Required | Recommended | PaaS private connectivity | Yes | Root resolves subnet_id from vnet pe_subnet_ids; module uses subnet_id |
| Private Endpoint | Security | Recommended | Private DNS zone group for automatic resolution | Required | Recommended | Name resolution over private link | Yes | private_dns_zone_id optional in module; pass zone ID when available |
| Private Endpoint | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## private-dns-zone (`modules/private-dns-zone`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Private DNS Zone | Security | Recommended | VNet links for resolution in intended VNets only | Required | Recommended | No public resolution | Yes | vnet_links with vnet_key; root passes vnet_ids so for_each keys are plan-time known |
| Private DNS Zone | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## bastion (`modules/bastion`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Bastion | Security | Mandatory | Dedicated AzureBastionSubnet (min /26) | Required | Required | Azure requirement | Yes | VNet tfvars: subnets.bastion with name AzureBastionSubnet, /26 |
| Bastion | Security | Mandatory | Standard SKU public IP, static | Required | Required | Stable endpoint | Yes | Root: public_ip module + bastion; subnet_id and public_ip_id resolved from keys |
| Bastion | Security | Optional | Restrict copy/paste, file copy, tunneling | Recommended | Optional | Reduce attack surface | Yes | copy_paste_enabled, file_copy_enabled, tunneling_enabled in module |
| Bastion | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## app-service (`modules/app-service`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| App Service Plan | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |
| Web App (Linux/Windows) | Security | Mandatory | HTTPS only | Required | Required | Data in transit | Yes | https_only in module |
| Web App | Security | Mandatory | FTPS disabled | Required | Required | Reduce attack surface | Yes | ftps_state = "Disabled" in site_config |
| Web App | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes | minimum_tls_version in site_config |
| Web App | Security | Recommended | System-assigned managed identity | Required | Recommended | No secrets in app settings | Yes | identity_type in web_apps; use Key Vault references for secrets |
| Web App | Security | Optional | Always On (prod) | Recommended | Optional | Avoid cold start | Yes | always_on in site_config |
| Web App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags; app_service_plan_key for plan resolution |

---

## function-app (`modules/function-app`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Function App | Security | Mandatory | HTTPS only, FTPS disabled, TLS 1.2 | Required | Required | Data in transit, reduce surface | Yes | ftps_state, minimum_tls_version in site_config |
| Function App | Security | Recommended | Storage via managed identity (no shared key) | Required | Recommended | Entra ID–based storage | Yes | use_storage_identity; storage_uses_managed_identity; AzureWebJobsStorage__accountName; RBAC Blob/Queue/Table Data Contributor |
| Function App | Security | Optional | Storage key from Key Vault reference when shared key enabled | Recommended | Optional | No secrets in config | Partial | Root resolves key from storage_account; use KV reference in prod when shared_access_key_enabled |
| Function App | Security | Recommended | Runtime version in allowed set (e.g. Node 18) | Required | Required | Supportability | Yes | node_version 12/14/16/18/20/22 in module |
| Function App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags; storage_account_key, app_service_plan_key resolved in root |

---

## logic-app (`modules/logic-app`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Logic App (Standard) | Security | Mandatory | Storage and plan; secrets via Key Vault reference when key used | Required | Required | No secrets in config | Partial | Root resolves storage key and plan_id; use KV ref for storage key in prod when shared key enabled |
| Logic App | Security | Recommended | Storage via managed identity (no shared key) | Required | Recommended | Entra ID–based storage | Yes | use_storage_identity; AzureWebJobsStorage__accountName; RBAC Blob/Queue/Table Data Contributor; provider requires non-empty key placeholder when identity used |
| Logic App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## api-management (`modules/api-management`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| API Management | Security | Recommended | System-assigned managed identity | Required | Recommended | Backend/Key Vault auth | Yes | identity_type in module |
| API Management | Security | Optional | VNet integration for private exposure | Recommended | Optional | Limit exposure | No | subnet_id not in current module; add if required |
| API Management | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## aks (`modules/aks`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| AKS | Security | Mandatory | Azure AD integration + Azure RBAC | Required | Recommended | Identity-based auth | Yes | enable_azure_rbac, admin_group_object_ids in module |
| AKS | Security | Mandatory | Network policy (e.g. azure) | Required | Recommended | Micro-segmentation | Yes | network_profile.network_policy in module |
| AKS | Security | Mandatory | Standard load balancer SKU | Required | Required | Production readiness | Yes | load_balancer_sku = "standard" in network_profile |
| AKS | Security | Optional | Node pool in VNet subnet | Recommended | Optional | Network isolation | Yes | default_node_pool.vnet_subnet_id via vnet_key/subnet_key in root |
| AKS | Security | Optional | Private cluster | Recommended | Optional | Limit control plane exposure | No | private_cluster_enabled not in module; add if required |
| AKS | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## registry (`modules/registry` – ACR)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Container Registry | Security | Mandatory | Admin user disabled | Required | Required | Use managed identity/AAD | Yes | admin_enabled = false in module |
| Container Registry | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled configurable in tfvars |
| Container Registry | Security | Optional | Customer-managed key (CMK) encryption | Recommended | Optional | Key control | Yes | encryption block (key_vault_key_id, identity_client_id) in module |
| Container Registry | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags; naming lowercase, no hyphens per Azure |

---

## mysql-flexible (`modules/mysql-flexible`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| MySQL Flexible Server | Security | Mandatory | Administrator password from TF_VAR/Key Vault | Required | Required | No secrets in repo | Partial | Sample in tfvars; use TF_VAR for administrator_password in prod; optional when Entra ID–first |
| MySQL Flexible Server | Security | Mandatory | Firewall rules restricted to app subnet in prod | Required | Required | Limit exposure | Yes | firewall_rules in module; use empty map when PE only |
| MySQL Flexible Server | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled in module |
| MySQL Flexible Server | Security | Optional | Backup retention, geo-redundant backup | Recommended | Optional | DR | Yes | backup_retention_days, geo_redundant_backup_enabled |
| MySQL Flexible Server | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root; name lowercase, hyphens allowed |

---

## redis (`modules/redis`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Redis Cache | Security | Mandatory | Non-SSL port disabled | Required | Required | Encryption in transit | Yes | non_ssl_port_enabled = false in module |
| Redis Cache | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes | minimum_tls_version = "1.2" in module |
| Redis Cache | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes | public_network_access_enabled in tfvars |
| Redis Cache | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## log-analytics (`modules/log-analytics`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Log Analytics Workspace | Security | Recommended | Retention per compliance (e.g. 90–365 days) | Required | Recommended | Audit, retention | Yes | retention_in_days in module |
| Log Analytics | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## application-insights (`modules/application-insights`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Application Insights | Security | Recommended | Link to Log Analytics for retention | Recommended | Optional | Unified retention | Yes | workspace_id in app_insights when provided |
| Application Insights | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## recovery-services-vault (`modules/recovery-services-vault`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Recovery Services Vault | Security | Mandatory | Soft delete enabled | Required | Required | Backup protection | Yes | soft_delete_enabled in module |
| Recovery Services Vault | Governance | Optional | Delete lock in prod | Recommended | Optional | Prevent accidental deletion | Yes | create_lock in tfvars |
| Recovery Services Vault | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## user-assigned-identity (`modules/user-assigned-identity`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| User-Assigned Identity | Security | Optional | Least privilege role assignments (outside module) | Recommended | Optional | Least privilege | N/A | Assign only required roles (e.g. Key Vault Secrets User) via RBAC; root role_assignments variable |
| User-Assigned Identity | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## nat-gateway (`modules/nat-gateway`)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| NAT Gateway | Security | Optional | Stable outbound IP for allow-listing | Recommended | Optional | Egress control | Yes | Module creates NAT gateway; associate to subnets in tfvars |
| NAT Gateway | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes | common_tags from root |

---

## Root: role_assignments (environments/dev, environments/prod)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| RBAC | Identity | Optional | Custom role assignments for users/groups on resources | Recommended | Optional | Least privilege, Entra ID access | Yes | role_assignments variable (scope_type, scope_key, role_definition_name, principal_id); azurerm_role_assignment.custom in root main.tf; see docs/ENTRA_ID_ACCESS.md |

---

*This document is the detailed security baseline status for all modules in this repository. Update when adding or changing modules or baseline controls.*
