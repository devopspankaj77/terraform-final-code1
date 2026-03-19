# Implementation Status – Terraform Azure Modules

This document tracks the implementation status of Azure resources in this Terraform module set. It aligns with the enterprise baseline and the canonical modules used by **environments/dev** and **environments/prod**.

**Legend:**

| Status | Description |
|--------|-------------|
| **Implemented** | Module exists; able to deploy and provide necessary configuration. |
| **Partially Implemented** | Module exists but requires refinement (e.g. runtime version, plan type, or extra rules). |
| **Not Implemented** | No module in this repository for the resource. |

**Last updated:** 2026-03-15

**Related:**  
- Azure Security Baseline (項目番号, 分類, 項目名, 現状, 備考): **[AZURE_SECURITY_BASELINE_STATUS.md](AZURE_SECURITY_BASELINE_STATUS.md)**  
- **Detailed security baseline status by module** (Resource \| Pillar \| Type \| Control \| Prod \| Non-Prod \| Reason \| Implemented \| Comments): **[SECURITY_BASELINE_STATUS_BY_MODULE.md](SECURITY_BASELINE_STATUS_BY_MODULE.md)**.

---

## Summary

| Status | Count |
|--------|-------|
| Implemented | 45 |
| Partially Implemented | 5 |
| Not Implemented | 50 |

---

## Detailed Status Table

| S. No. | Resource | Module Name | Status | Comments | Ref |
|--------|----------|-------------|--------|----------|-----|
| 1 | Resource Group | `resource-group` | Implemented | Deploy with tags, optional lock. | Done |
| 2 | Virtual Network (VNET) | `vnet` | Implemented | Subnets, address space, optional DNS. | Done |
| 3 | Subnets | `vnet` | Implemented | Per-subnet or shared; optional PE subnet. | Done |
| 4 | Network Security Group (NSG) | `vnet` | Implemented | NSG and rules within vnet module. | Done |
| 5 | NSG Rules | `vnet` | Implemented | Configurable rules; prefix/prefixes handled. | Done |
| 6 | Public IP Address | `azurerm_public_ip` | Implemented | Standard SKU, static; used for Bastion/NAT. | Done |
| 7 | Network Interface (NIC) | `vm`, `vm-windows` | Implemented | Created inside VM modules. | Done |
| 8 | Virtual Machine (Linux) | `vm` | Implemented | Linux VM with optional extensions, AAD login. | Done |
| 9 | Virtual Machine (Windows) | `vm-windows` | Implemented | Windows VM with optional extensions, AAD login. | Done |
| 10 | Storage Account | `storage-account` | Implemented | TLS 1.2, HTTPS only, optional versioning. | Done |
| 11 | Blob Container | `storage-account` | Implemented | Containers with access type. | Done |
| 12 | Key Vault | `keyvault` | Implemented | RBAC, soft delete, purge protection, network ACLs. | Done |
| 13 | Key Vault Access Policy / RBAC | `keyvault` | Implemented | RBAC authorization supported. | Done |
| 14 | Key Vault Secret | `key-vault-secret` | Implemented | Secrets with optional content type. | Done |
| 15 | SQL Server | `sql` | Implemented | TLS, firewall rules, optional Azure AD admin. | Done |
| 16 | SQL Database | `sql` | Implemented | Databases with retention, SKU. | Done |
| 17 | SQL Firewall Rule | `sql` | Implemented | Firewall rules in sql module. | Done |
| 18 | Private Endpoint | `private-endpoint` | Implemented | Subnet + resource ID; optional private DNS. | Done |
| 19 | Private DNS Zone | `private-dns-zone` | Implemented | Zones with VNet links (vnet_key resolution). | Done |
| 20 | Private DNS Zone VNet Link | `private-dns-zone` | Implemented | Links with plan-time known keys. | Done |
| 21 | Azure Bastion Host | `bastion` | Implemented | Dedicated subnet, public IP; copy/paste, IP connect. | Done |
| 22 | App Service Plan | `app-service` | Implemented | Linux/Windows, SKU (B1, P1v2, etc.). | Done |
| 23 | Windows Web App | `app-service` | Implemented | FTPS disabled, TLS, app settings. | Done |
| 24 | Linux Web App | `app-service` | Implemented | FTPS disabled, TLS, app settings. | Done |
| 25 | Azure Container Registry (ACR) | `registry` | Implemented | Admin disabled, optional network rules. | Done |
| 26 | Azure Kubernetes Service (AKS) | `aks` | Implemented | Node pool, Azure RBAC, network profile. | Done |
| 27 | MySQL Flexible Server | `mysql-flexible` | Implemented | Backup, firewall, storage block. | Done |
| 28 | MySQL Firewall Rule | `mysql-flexible` | Implemented | Firewall rules in mysql-flexible module. | Done |
| 29 | Log Analytics Workspace | `log-analytics` | Implemented | Retention, SKU. | Done |
| 30 | Application Insights | `application-insights` | Implemented | Optional workspace link. | Done |
| 31 | API Management Service | `api-management` | Implemented | Publisher, SKU, identity. | Done |
| 32 | Logic App (Standard) | `logic-app` | Implemented | Storage + App Service Plan. | Done |
| 33 | Recovery Services Vault | `recovery-services-vault` | Implemented | Soft delete, optional lock. | Done |
| 34 | User-Assigned Managed Identity | `user-assigned-identity` | Implemented | Principal ID, client ID outputs. | Done |
| 35 | NAT Gateway | `nat-gateway` | Implemented | Outbound static IP. | Done |
| 36 | Azure Redis Cache | `redis` | Implemented | TLS, non-SSL port disabled. | Done |
| 37 | VNet Peering | `vnet` | Partially Implemented | Not in current vnet module; can be refined per requirement. | Need to be refined |
| 38 | Function App (Linux/Windows) | `function-app` | Partially Implemented | Deploy works; runtime version (e.g. Node 18) and consumption plan need validation. | Runtime version and consumption plan |
| 39 | Function App (Node.js) | `function-app` | Partially Implemented | Same as above; node_version in allowed set (12, 14, 16, 18, 20, 22). | Runtime version and consumption plan |
| 40 | Application Gateway | — | Not Implemented | No `app-gateway` module. | Not yet |
| 41 | WAF Policy | — | Not Implemented | No dedicated WAF module; would align with App Gateway. | Not yet |
| 42 | Virtual Network Gateway | — | Not Implemented | No `vnet-gateway` module. | Not yet |
| 43 | Local Network Gateway | — | Not Implemented | No `local-gateway` module. | Not yet |
| 44 | Connection (VPN) | — | Not Implemented | No connection resource in repo. | Not yet |
| 45 | Azure Front Door | — | Not Implemented | No `front-door` module. | Not yet |
| 46 | Azure Container Instance (ACI) | — | Not Implemented | No `aci` module. | Not yet |
| 47 | Cosmos DB Account | — | Not Implemented | No `cosmos-db` module. | Not yet |
| 48 | Cosmos DB SQL API Database | — | Not Implemented | No `cosmos-db` module. | Not yet |
| 49 | Cosmos DB SQL API Container | — | Not Implemented | No `cosmos-db` module. | Not yet |
| 50 | Azure SQL Managed Instance | — | Not Implemented | No `sql-managed-instance` module. | Not yet |
| 51 | Azure Data Lake Storage Gen2 | — | Not Implemented | No `data-lake` module. | Not yet |
| 52 | Azure Monitor Alert | — | Not Implemented | No `monitor-alert` module. | Not yet |
| 53 | Service Bus Namespace | — | Not Implemented | No `service-bus` module. | Not yet |
| 54 | Service Bus Queue | — | Not Implemented | No `service-bus` module. | Not yet |
| 55 | Service Bus Topic | — | Not Implemented | No `service-bus` module. | Not yet |
| 56 | Service Bus Subscription | — | Not Implemented | No `service-bus` module. | Not yet |
| 57 | Event Hubs Namespace | — | Not Implemented | No `event-hubs` module. | Not yet |
| 58 | Event Hub | — | Not Implemented | No `event-hubs` module. | Not yet |
| 59 | Event Hub Consumer Group | — | Not Implemented | No `event-hubs` module. | Not yet |
| 60 | Azure Data Factory (ADF) | — | Not Implemented | No `data-factory` module. | Not yet |
| 61 | Azure Search Service | — | Not Implemented | No `search-service` module. | Not yet |
| 62 | CDN Profile | — | Not Implemented | No `cdn` module. | Not yet |
| 63 | CDN Endpoint | — | Not Implemented | No `cdn` module. | Not yet |
| 64 | Azure Backup Vault | — | Not Implemented | No `backup` module; RSV present. | Not yet |
| 65 | Backup Policy | — | Not Implemented | No backup policy resource. | Not yet |
| 66 | Site Recovery Protection Policy | — | Not Implemented | No Site Recovery module. | Not yet |
| 67 | Azure Firewall | — | Not Implemented | No `azure-firewall` module. | Not yet |
| 68 | Firewall Policy | — | Not Implemented | No firewall policy module. | Not yet |
| 69 | Load Balancer | — | Not Implemented | No `load-balancer` module. | Not yet |
| 70 | Traffic Manager | — | Not Implemented | No `traffic-manager` module. | Not yet |
| 71 | DNS Zone | — | Not Implemented | No `dns-zone` module (private DNS only). | Not yet |
| 72 | DNS Zone Record Set | — | Not Implemented | No public DNS module. | Not yet |
| 73 | Azure AD Identity Protection Policy | — | Not Implemented | No `aad-identity-protection` module. | Not yet |
| 74 | Azure AD User | — | Not Implemented | No `aad-user` module. | Not yet |
| 75 | Azure AD Group | — | Not Implemented | No `aad-group` module. | Not yet |
| 76 | Service Principal | — | Not Implemented | No `aad-sp` module. | Not yet |
| 77 | Azure AD Application | — | Not Implemented | No `aad-app` module. | Not yet |
| 78 | Role Assignment | — | Not Implemented | No `aad-role-assignment` module. | Not yet |
| 79 | Azure Policy Assignment | — | Not Implemented | No `azure-policy` module. | Not yet |
| 80 | Azure Policy Definition | — | Not Implemented | No `azure-policy` module. | Not yet |
| 81 | Azure Blueprint Assignment | — | Not Implemented | No `azure-blueprint` module. | Not yet |
| 82 | Azure Blueprint Definition | — | Not Implemented | No `azure-blueprint` module. | Not yet |
| 83 | Azure Monitor Log Profile | — | Not Implemented | No `monitor-log-profile` module. | Not yet |
| 84 | Diagnostic Setting | — | Not Implemented | No `monitor-diagnostic-setting` module. | Not yet |
| 85 | Automation Account | — | Not Implemented | No `automation-account` module. | Not yet |
| 86 | Runbook | — | Not Implemented | No runbook resource. | Not yet |
| 87 | Queue Storage | — | Not Implemented | Storage account has blob/container only. | Not yet |
| 88 | Table Storage | — | Not Implemented | No table resource in storage module. | Not yet |
| 89 | File Share | — | Not Implemented | No file share in storage module. | Not yet |
| 90 | Data Lake Analytics Account | — | Not Implemented | No `data-lake-analytics` module. | Not yet |
| 91 | Data Lake Store Gen1 | — | Not Implemented | No `data-lake-store` module. | Not yet |
| 92 | Data Explorer Cluster | — | Not Implemented | No `data-explorer` module. | Not yet |
| 93 | Data Explorer Database | — | Not Implemented | No `data-explorer` module. | Not yet |
| 94 | Machine Learning Workspace | — | Not Implemented | No `ml-workspace` module. | Not yet |
| 95 | Batch Account | — | Not Implemented | No `batch-account` module. | Not yet |
| 96 | Cosmos DB Cassandra / Gremlin / MongoDB / Table API | — | Not Implemented | No Cosmos DB module. | Not yet |
| 97 | Event Grid Topic | — | Not Implemented | No `event-grid` module. | Not yet |
| 98 | Event Grid Subscription | — | Not Implemented | No `event-grid` module. | Not yet |
| 99 | Azure Stream Analytics Job | — | Not Implemented | No `stream-analytics` module; input/output would need refinement. | Not yet |
| 100 | Azure Databricks Workspace | — | Not Implemented | No `databricks` module; notebooks would need refinement. | Not yet |

---

## Module-to-Path Reference (This Repository)

| Module Name | Path | Status |
|-------------|------|--------|
| resource-group | `modules/resource-group` | Implemented |
| vnet | `modules/vnet` | Implemented |
| azurerm_public_ip | `modules/azurerm_public_ip` | Implemented |
| vm | `modules/vm` | Implemented |
| vm-windows | `modules/vm-windows` | Implemented |
| storage-account | `modules/storage-account` | Implemented |
| keyvault | `modules/keyvault` | Implemented |
| key-vault-secret | `modules/key-vault-secret` | Implemented |
| sql | `modules/sql` | Implemented |
| private-endpoint | `modules/private-endpoint` | Implemented |
| private-dns-zone | `modules/private-dns-zone` | Implemented |
| bastion | `modules/bastion` | Implemented |
| app-service | `modules/app-service` | Implemented |
| function-app | `modules/function-app` | Partially Implemented |
| logic-app | `modules/logic-app` | Implemented |
| api-management | `modules/api-management` | Implemented |
| registry (ACR) | `modules/registry` | Implemented |
| aks | `modules/aks` | Implemented |
| mysql-flexible | `modules/mysql-flexible` | Implemented |
| redis | `modules/redis` | Implemented |
| log-analytics | `modules/log-analytics` | Implemented |
| application-insights | `modules/application-insights` | Implemented |
| recovery-services-vault | `modules/recovery-services-vault` | Implemented |
| user-assigned-identity | `modules/user-assigned-identity` | Implemented |
| nat-gateway | `modules/nat-gateway` | Implemented |

---

## Partially Implemented – Follow-up

| Resource | Gap | Suggested action |
|----------|-----|------------------|
| VNet Peering | Not in vnet module | Add optional peering block or separate peering module; refine for hub-spoke etc. |
| Function App | Runtime version (e.g. Node 18), consumption plan | Validate `node_version` (12/14/16/18/20/22); add consumption plan support if required. |
| WAF Policy | N/A (no App Gateway) | When adding App Gateway, add WAF policy with configurable rules. |
| Stream Analytics | No module | Add module; refine input/output bindings. |
| Databricks | No module | Add module; refine notebooks integration. |

---

## Implementation Status by Control (All Resources)

Format: **Resource** | **Pillar** | **Type** | **Control** | **Prod** | **Non-Prod** | **Reason** | **Implemented** | **Comments**

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|---------|
| Resource Group | Governance | Mandatory | Naming convention [e.g. rg-&lt;org&gt;-&lt;app&gt;-&lt;env&gt;-&lt;work&gt;] | Required | Required | Consistency, cost tracking | Yes (Env tfvars) | — |
| Resource Group | Governance | Mandatory | Mandatory tags (Created By, Created Date, Environment, Requester, Ticket Reference, Project Name) | Required | Required | Audit, chargeback | Yes (main.tf common_tags) | — |
| Resource Group | Governance | Optional | Additional tags (Owner, Cost Center, Data Classification) | Recommended | Optional | FinOps, compliance | Yes (additional_tags tfvars) | — |
| Resource Group | Governance | Mandatory | Delete lock (CanNotDelete) | Required | Optional | Prevent accidental deletion | Yes (resource-group module create_lock, lock_level) | — |
| Resource Group | Governance | Mandatory | No resources without tags | Required | Required | Enforce via policy | Yes (tags passed to all modules) | — |
| Resource Group | Cost Optimization | Recommended | Single RG per env/workload or per application boundary | Recommended | Recommended | Clear ownership, chargeback | Yes (Env design) | — |
| Resource Group | Cost Optimization | Optional | Budget alerts on RG | Recommended | Optional | Cost visibility | No | Create budget + alerts in Azure Cost Management or separate Terraform |
| Resource Group | Operational Excellence | Optional | Document RG purpose in naming or tag | Recommended | Optional | Discoverability | Partial (naming/tag in tfvars) | Add tag e.g. Purpose/Description in additional_tags if needed |

### Virtual Network (VNet)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Virtual Network (VNet) | Security | Mandatory | NSG on all subnets (except AzureBastionSubnet) | Required | Required | Network segmentation | Yes (vnet module create_nsg, nsg_per_subnet) | — |
| Virtual Network (VNet) | Security | Mandatory | No 0.0.0.0/0 for management ports (RDP 3389, SSH 22) in NSG | Required | Required | Limit exposure | Partial (jump_rdp_source_cidr, jump_ssh_source_cidr) | Set TF_VAR_jump_rdp_source_cidr / jump_ssh_source_cidr to VPN/bastion CIDR in prod |
| Virtual Network (VNet) | Security | Mandatory | Private endpoint subnet with network policies disabled | Required | Recommended | PaaS private connectivity | Yes (vnet module PE subnet private_endpoint_network_policies) | — |
| Virtual Network (VNet) | Security | Mandatory | Deny by default, explicit allow rules only | Required | Required | Least privilege | Yes (nsg_rules are explicit allow) | — |
| Virtual Network (VNet) | Security | Recommended | Restrict inter-subnet traffic where not needed | Recommended | Recommended | Micro-segmentation | Partial (env-defined nsg_rules) | Define nsg_rules per subnet in tfvars with minimal source/dest CIDRs |
| Virtual Network (VNet) | Security | Optional | DDoS Protection Standard (optional for critical) | Recommended | Optional | Availability | No | Enable DDoS Plan and associate to VNet via separate Terraform or portal |
| Virtual Network (VNet) | Governance | Mandatory | No overlapping address space across envs | Required | Required | No routing conflicts | Yes (Env tfvars design) | — |

### Storage Account

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Storage Account | Security | Mandatory | HTTPS only (no HTTP) | Required | Required | Data in transit protection | Yes (storage-account module https_traffic_only_enabled) | — |
| Storage Account | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes (min_tls_version TLS1_2) | — |
| Storage Account | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled configurable) | Use private_endpoints in tfvars for prod |
| Storage Account | Security | Optional | Blob versioning for critical data | Recommended | Optional | Data recovery | Yes (enable_blob_versioning in module) | — |
| Storage Account | Security | Optional | Container soft delete retention | Recommended | Optional | Accidental delete recovery | Yes (blob/container_soft_delete_retention_days in tfvars) | — |
| Storage Account | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Key Vault

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Key Vault | Security | Mandatory | RBAC only (no access policies) | Required | Required | Least privilege, audit | Yes (keyvault module rbac_authorization_enabled) | — |
| Key Vault | Security | Mandatory | Soft delete enabled | Required | Required | Accidental delete recovery | Yes (soft_delete_retention_days) | — |
| Key Vault | Security | Mandatory | Purge protection in prod | Required | Optional | Prevent permanent loss | Yes (purge_protection_enabled in tfvars) | — |
| Key Vault | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled configurable) | — |
| Key Vault | Security | Optional | Delete lock | Recommended | Optional | Prevent accidental deletion | Yes (create_delete_lock in keyvault tfvars) | — |
| Key Vault | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Key Vault Secret

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Key Vault Secret | Security | Mandatory | Secret value from variable / TF_VAR / KV (no plain text in repo) | Required | Required | No secrets in code | Partial (key-vault-secret module; use TF_VAR_* or KV reference) | Never commit secret_value in tfvars for prod |
| Key Vault Secret | Governance | Optional | Content type for clarity | Optional | Optional | Discoverability | Yes (content_type in module) | — |

### SQL Server / SQL Database

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| SQL Server | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes (sql module minimum_tls_version) | — |
| SQL Server | Security | Mandatory | Firewall rules (no 0.0.0.0/0 in prod) | Required | Required | Limit exposure | Yes (firewall_rules in tfvars) | Restrict to VNet/subnet in prod |
| SQL Server | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled) | — |
| SQL Server | Security | Optional | Azure AD administrator | Recommended | Optional | Identity-based auth | Yes (azuread_administrator in module) | — |
| SQL Database | Security | Optional | Short-term retention (backup) | Recommended | Optional | Point-in-time restore | Yes (short_term_retention_days in databases) | — |
| SQL Server/Database | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Private Endpoint & Private DNS Zone

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Private Endpoint | Security | Mandatory | Use dedicated PE subnet (policies disabled) | Required | Recommended | PaaS private connectivity | Yes (vnet pe_subnet + private-endpoint module) | — |
| Private Endpoint | Security | Recommended | Private DNS zone group for automatic resolution | Required | Recommended | Name resolution over private link | Yes (private_dns_zone_id optional in module) | Pass zone ID from private_dns_zone when needed |
| Private DNS Zone | Security | Recommended | VNet links for resolution in intended VNets only | Required | Recommended | No public resolution | Yes (private-dns-zone module vnet_links, vnet_ids from root) | — |
| Private Endpoint / DNS | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Bastion

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Bastion | Security | Mandatory | Dedicated AzureBastionSubnet (min /26) | Required | Required | Azure requirement | Yes (vnet subnets.bastion in tfvars) | — |
| Bastion | Security | Mandatory | Standard SKU public IP, static | Required | Required | Stable endpoint | Yes (public_ip + bastion module) | — |
| Bastion | Security | Optional | Restrict copy/paste, file copy, tunneling if not needed | Recommended | Optional | Reduce attack surface | Yes (copy_paste_enabled, file_copy_enabled, tunneling_enabled in module) | — |
| Bastion | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Virtual Machine (Linux / Windows)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| VM (Linux) | Security | Mandatory | SSH only; disable password auth in prod | Required | Recommended | Limit exposure | Yes (vm module disable_password_authentication) | Use SSH key; set true in prod tfvars |
| VM (Windows) | Security | Mandatory | Strong password policy (Azure enforced) | Required | Required | Credential strength | Yes (vm-windows module) | Use TF_VAR for admin_password in prod |
| VM (Linux/Windows) | Security | Mandatory | No public IP unless jump box | Required | Optional | Limit exposure | Yes (create_public_ip configurable) | — |
| VM (Linux/Windows) | Security | Mandatory | System-assigned managed identity | Required | Required | Key Vault / storage access without secrets | Yes (identity_type in vm / vm-windows) | — |
| VM (Linux/Windows) | Security | Recommended | Azure AD login extension | Recommended | Recommended | Identity-based sign-in | Yes (enable_aad_login_extension in module) | Assign VM Admin Login role in Azure AD |
| VM (Linux/Windows) | Security | Optional | Encryption at host, Secure Boot, vTPM | Recommended | Optional | Confidential computing | Yes (encryption_at_host_enabled, secure_boot_enabled, vtpm_enabled) | — |
| VM (Linux/Windows) | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### App Service Plan & Web App

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| App Service / Web App | Security | Mandatory | HTTPS only | Required | Required | Data in transit | Yes (app-service module https_only) | — |
| App Service / Web App | Security | Mandatory | FTPS disabled | Required | Required | Reduce attack surface | Yes (ftps_state = Disabled in site_config) | — |
| App Service / Web App | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes (minimum_tls_version in site_config) | — |
| App Service / Web App | Security | Recommended | System-assigned managed identity | Required | Recommended | No secrets in app settings | Yes (identity_type in web_apps) | Use Key Vault references for secrets |
| App Service / Web App | Security | Optional | Always On (prod) | Recommended | Optional | Avoid cold start | Yes (always_on in site_config) | — |
| App Service / Web App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Function App

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Function App | Security | Mandatory | HTTPS only, FTPS disabled, TLS 1.2 | Required | Required | Data in transit, reduce surface | Yes (function-app module) | — |
| Function App | Security | Recommended | Storage key from Key Vault reference in prod | Required | Optional | No secrets in config | Partial (storage_account_access_key from module; use KV reference in prod) | Prefer Key Vault reference for storage key in prod |
| Function App | Security | Recommended | Runtime version in allowed set (e.g. Node 18) | Required | Required | Supportability | Yes (node_version 12/14/16/18/20/22 in module) | — |
| Function App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Logic App

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Logic App (Standard) | Security | Mandatory | Storage and plan from module; secrets via KV reference | Required | Required | No secrets in config | Partial (storage key from root resolution; use KV ref in prod) | — |
| Logic App | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### API Management

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| API Management | Security | Recommended | System-assigned managed identity | Required | Recommended | Backend / Key Vault auth | Yes (api-management module identity_type) | — |
| API Management | Security | Optional | VNet integration for private exposure | Recommended | Optional | Limit exposure | No (subnet_id not in current module) | Add subnet_id to module if required |
| API Management | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Azure Kubernetes Service (AKS)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| AKS | Security | Mandatory | Azure AD integration + Azure RBAC | Required | Recommended | Identity-based auth | Yes (aks module enable_azure_rbac, admin_group_object_ids) | — |
| AKS | Security | Mandatory | Network policy (e.g. azure) | Required | Recommended | Micro-segmentation | Yes (network_profile.network_policy) | — |
| AKS | Security | Mandatory | Standard load balancer SKU | Required | Required | Production readiness | Yes (load_balancer_sku = standard) | — |
| AKS | Security | Optional | Node pool in VNet subnet | Recommended | Optional | Network isolation | Yes (default_node_pool.vnet_subnet_id via vnet_key/subnet_key) | — |
| AKS | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Container Registry (ACR)

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Container Registry | Security | Mandatory | Admin user disabled | Required | Required | Use managed identity / AAD | Yes (registry module admin_enabled = false) | — |
| Container Registry | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled configurable) | — |
| Container Registry | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### MySQL Flexible Server

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| MySQL Flexible Server | Security | Mandatory | Administrator password from TF_VAR / Key Vault | Required | Required | No secrets in repo | Partial (tfvars sample; use TF_VAR in prod) | — |
| MySQL Flexible Server | Security | Mandatory | Firewall rules restricted to app subnet in prod | Required | Required | Limit exposure | Yes (firewall_rules in mysql-flexible module) | — |
| MySQL Flexible Server | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled) | — |
| MySQL Flexible Server | Security | Optional | Backup retention, geo-redundant backup | Recommended | Optional | DR | Yes (backup_retention_days, geo_redundant_backup_enabled) | — |
| MySQL Flexible Server | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Redis Cache

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Redis Cache | Security | Mandatory | Non-SSL port disabled | Required | Required | Encryption in transit | Yes (redis module non_ssl_port_enabled = false) | — |
| Redis Cache | Security | Mandatory | Minimum TLS 1.2 | Required | Required | Encryption in transit | Yes (minimum_tls_version = "1.2") | — |
| Redis Cache | Security | Recommended | Public network access disabled when using PE | Required | Optional | Limit exposure | Yes (public_network_access_enabled in tfvars) | — |
| Redis Cache | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Log Analytics & Application Insights

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Log Analytics | Security | Recommended | Retention per compliance (e.g. 90–365 days) | Required | Recommended | Audit, retention | Yes (log-analytics module retention_in_days) | — |
| Log Analytics | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |
| Application Insights | Security | Recommended | Link to Log Analytics for retention | Recommended | Optional | Unified retention | Yes (workspace_id in app_insights) | — |
| Application Insights | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Recovery Services Vault

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Recovery Services Vault | Security | Mandatory | Soft delete enabled | Required | Required | Backup protection | Yes (recovery-services-vault module soft_delete_enabled) | — |
| Recovery Services Vault | Governance | Optional | Delete lock in prod | Recommended | Optional | Prevent accidental deletion | Yes (create_lock in tfvars) | — |
| Recovery Services Vault | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### User-Assigned Managed Identity & NAT Gateway

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| User-Assigned Identity | Security | Optional | Least privilege role assignments (outside module) | Recommended | Optional | Least privilege | N/A | Assign only required roles (e.g. Key Vault Secrets User) |
| User-Assigned Identity | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |
| NAT Gateway | Security | Optional | Stable outbound IP for allow-listing | Recommended | Optional | Egress control | Yes (nat-gateway module) | — |
| NAT Gateway | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

### Public IP

| Resource | Pillar | Type | Control | Prod | Non-Prod | Reason | Implemented | Comments |
|----------|--------|------|---------|------|----------|--------|--------------|----------|
| Public IP | Security | Mandatory | Standard SKU, static allocation | Required | Required | Stable endpoint | Yes (azurerm_public_ip module) | — |
| Public IP | Governance | Mandatory | Naming and mandatory tags | Required | Required | Consistency, audit | Yes (tfvars + common_tags) | — |

---

*This file is the single source of truth for implementation status in this Terraform Azure module set. Update it when adding or changing modules.*
