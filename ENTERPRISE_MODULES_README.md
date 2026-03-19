# Enterprise Terraform Modules – Overview

This repository includes **enterprise-grade root and child modules** for Azure, with naming conventions, mandatory tagging, optional arguments, and security baselines applied across resources.

## Naming Convention

Pattern: **`jsr-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload>`**

- **INT** = Internal project  
- **CLT** = Client project  
- Examples:
  - VM: `jsr-002-Azure-LIN-INT-IT-Sonar`
  - Web App: `jsr-055-Azure-INT-Web-App-RAT-QA`
  - RG: `jsr-002-Azure-INT-RG-Bank-Dev`
  - VNet: `jsr-002-Azure-INT-VNet-Bank-Dev`
- **Storage / ACR**: No hyphens (Azure limit); e.g. `jsr002azureintstobankdev`, `jsr002azureintacrbankdev`
- **Key Vault**: Max 24 characters; e.g. `jsr-002-kv-bankdev`

## Company-Mandatory Tags

Set these in `dev.tfvars` / `prod.tfvars` (or via TF_VAR):

- **Created By**
- **Created Date** (YYYY-MM-DD; null = apply date)
- **Environment** (dev, uat, prod)
- **Requester**
- **Ticket Reference**
- **Project Name**

## Module Layout

### Child modules (under `modules/`)

| Module | Purpose | Security / options |
|--------|--------|---------------------|
| **resource-group** | Resource groups | Optional delete lock, `lock_level` |
| **vnet** | Virtual networks, subnets, NSG, NSG rules | Optional PE subnet, per-subnet or single NSG, explicit rules only |
| **vm** | Linux VMs | SSH/AAD, managed identity, boot diag, encryption at host, optional public IP |
| **vm-windows** | Windows VMs | RDP + AAD login, managed identity, boot diag, encryption at host, patch mode, WinRM optional |
| **storage-account** | Storage accounts + containers | HTTPS only, min TLS 1.2, blob/container soft delete, network rules, optional lock |
| **keyvault** | Key Vaults | RBAC, soft delete, purge protection, network_acls, optional lock |
| **key-vault-secret** | KV secrets | Value from variable (sensitive); use TF_VAR or KV reference |
| **sql** | SQL Server + databases | Min TLS 1.2, firewall rules, Azure AD admin, short-term retention |
| **private-endpoint** | Private endpoints | Optional `private_dns_zone_id` for auto DNS |
| **private-dns-zone** | Private DNS zones + VNet links | For PE resolution |
| **registry** | ACR | `admin_enabled = false`, optional `public_network_access_enabled = false` |
| **azurerm_public_ip** | Public IPs | Standard SKU, static; used by root for Bastion/NAT/VMs |

### Root (environments)

- **environments/dev** – Dev root: `main.tf`, `variables.tf`, `locals.tf`, `dev.tfvars`, `dev.tfvars.example`
- **environments/prod** – Prod root: same structure; defaults (e.g. `create_lock`) tuned for production

Resources are created only when the corresponding variable map is non-empty (e.g. `resource_groups`, `vnets`, `key_vaults`).

## Security Baseline (aligned with your SECURITY_BASELINE)

- **RG**: Optional `create_lock` / `lock_level`
- **VNet**: NSG with explicit rules; optional PE subnet (policies disabled)
- **VM**: No public IP by default; SSH keys / AAD; managed identity; encryption at host; boot diagnostics
- **Storage**: HTTPS only, min TLS 1.2, soft delete, optional lock; use PE when `public_network_access_enabled = false`
- **Key Vault**: RBAC only, soft delete (e.g. 90d), purge protection, no public access when using PE
- **SQL**: Min TLS 1.2, firewall rules, Azure AD admin, short-term retention on DBs
- **ACR**: `admin_enabled = false`; `public_network_access_enabled = false` when using PE
- **Secrets**: No secrets in committed tfvars; use `TF_VAR_*` or Key Vault
- **Jump VM**: Restrict RDP/SSH via `jump_rdp_source_cidr` / `jump_ssh_source_cidr` (TF_VAR in prod)

## Quick Start (Dev)

1. Copy `dev.tfvars.example` to `dev.tfvars` and set company tags + naming.
2. Ensure backend is configured (e.g. in `provider.tf` or `backend.tf`).
3. From `environments/dev`:
   - `terraform init`
   - `terraform plan -var-file=dev.tfvars`
   - `terraform apply -var-file=dev.tfvars` (no `-auto-approve` in prod)

To add more resources, uncomment or extend the corresponding blocks in `dev.tfvars` (e.g. `storage_accounts`, `key_vaults`, `sql_servers`, `registries`, `windows_vms`) and set required attributes; optional ones have defaults in the modules. For **Windows VMs**, use the `windows_vms` map and set `admin_password` via `TF_VAR` or Key Vault (do not commit passwords).

## Optional Security / TFVARS Reference

See **OPTIONAL_SECURITY_TFVARS.md** (if present) and the **SECURITY OPTIONS REFERENCE** section at the end of `dev.tfvars.example` / `prod.tfvars.example` for all optional keys (locks, PE, NSG sources, retention, etc.).

## Backend

Use a remote backend (e.g. `azurerm`) for state; restrict access with RBAC and optional private endpoint. See your security baseline document (section 12.1) for steps.
