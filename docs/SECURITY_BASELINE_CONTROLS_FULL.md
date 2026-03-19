# Security Baseline Controls – Full List (by CONTROL ID)

Format: **CONTROL ID** | **CONTROL FAMILY** | **CONTROL NAME** | **MODULE** | **STATUS**  
Status: **Impl** = Implemented, **N/A** = Not Applicable, **Partial** = Partially implemented.

---

| CONTROL ID | CONTROL FAMILY | CONTROL NAME | MODULE | STATUS |
|------------|----------------|--------------|--------|--------|
| GV.BP.1 | Governance | Implement resource naming convention (e.g. ICR-&lt;nnn&gt;-Azure-&lt;INT\|CLT&gt;-&lt;ResourceType&gt;-&lt;Workload&gt;; see docs/NAMING_CONVENTION.md) | resource-group | Impl |
| GV.BP.2 | Governance | Apply mandatory tags (Created By, Created Date, Environment, Requester, Ticket Reference, Project Name, Subscription Id) to all resources | resource-group (common_tags root) | Impl |
| GV.BP.3 | Governance | Apply additional tags (Owner, Cost Center, Data Classification) where required | resource-group | Impl |
| GV.BP.4 | Governance | Enforce delete lock (CanNotDelete) on critical resource groups | resource-group | Impl |
| GV.BP.5 | Governance | Ensure no resources are deployed without tags | All modules | Impl |
| GV.BP.6 | Governance | Single resource group per environment or workload boundary | resource-group | Impl |
| GV.BP.7 | Governance | Document resource group purpose in naming or tag | resource-group | Partial |
| NS.BP.1 | Network Security | Implement network security best practices for virtual network topology | vnet | Impl |
| NS.BP.2 | Network Security | Implement network segmentation using subnets and address space | vnet | Impl |
| NS.BP.3 | Network Security | Attach NSG on all subnets (except AzureBastionSubnet) | vnet | Impl |
| NS.BP.4 | Network Security | Support per-subnet or shared NSG model | vnet | Impl |
| NS.SG.1 | Network Security | Implement NSG rules for inbound and outbound traffic with explicit allow only | vnet | Impl |
| NS.SG.2 | Network Security | Restrict management ports (RDP 3389, SSH 22); no 0.0.0.0/0 in production | vnet | Partial |
| NS.SG.3 | Network Security | Deny by default; explicit allow rules only | vnet | Impl |
| NS.SG.4 | Network Security | Restrict inter-subnet traffic where not needed via NSG rules | vnet | Partial |
| NS.PE.1 | Network Security | Provide dedicated private endpoint subnet with network policies disabled | vnet | Impl |
| NS.PE.2 | Network Security | No overlapping address space across environments | vnet | Impl |
| NS.PIP.1 | Network Security | Use Standard SKU and static allocation for public IPs | azurerm_public_ip | Impl |
| NS.BA.1 | Network Security | Use dedicated AzureBastionSubnet (min /26) for Bastion | vnet + bastion | Impl |
| NS.BA.2 | Network Security | Use Standard SKU static public IP for Bastion | azurerm_public_ip + bastion | Impl |
| NS.BA.3 | Network Security | Restrict Bastion copy/paste, file copy, tunneling as needed | bastion | Impl |
| NS.NAT.1 | Network Security | Provide stable outbound IP via NAT Gateway for allow-listing | nat-gateway | Impl |
| NS.DNS.1 | Network Security | Use private DNS zones for private endpoint resolution | private-dns-zone | Impl |
| NS.DNS.2 | Network Security | Link private DNS zones only to intended VNets | private-dns-zone | Impl |
| NS.PR.1 | Network Security | Create private endpoints using dedicated PE subnet | private-endpoint | Impl |
| NS.PR.2 | Network Security | Associate private DNS zone group on private endpoint for automatic resolution | private-endpoint | Impl |
| IA.BP.1 | Identity and Access Management | Implement strong authentication mechanisms for VM access | vm, vm-windows | Impl |
| IA.BP.2 | Identity and Access Management | Prefer SSH key; disable password authentication on Linux VMs in prod | vm | Impl |
| IA.BP.3 | Identity and Access Management | Enforce strong password policy for Windows VMs (Azure enforced) | vm-windows | Impl |
| OS.GPC.01 | Windows OS Baseline | Account lockout policy (duration ≥10 min, threshold ≤10, reset ≥10 min) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| OS.GPC.02 | Windows OS Baseline | Password policy (complexity, length 14, max age 90, history 24) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| OS.GPC.03 | Windows OS Baseline | User rights (deny network logon for Guests) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| OS.AUDIT.01 | Windows OS Baseline | Audit policy (logon/logoff, account logon, object access, policy change, privilege use, system) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| OS.SEC.01 | Windows OS Baseline | Security options (NTLM level, NoLMHash, restrict anonymous, SMB signing) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| OS.SVC.01 | Windows OS Baseline | Disable high-risk services (e.g. Telnet) | vm-windows (Apply-WindowsSecurityBaseline.ps1) | Impl |
| IA.MI.1 | Identity and Access Management | Enable system-assigned managed identity on VMs | vm, vm-windows | Impl |
| IA.MI.2 | Identity and Access Management | Enable system-assigned managed identity on App Service / Web App | app-service | Impl |
| IA.MI.3 | Identity and Access Management | Enable system-assigned managed identity on Function App | function-app | Impl |
| IA.MI.4 | Identity and Access Management | Enable system-assigned managed identity on API Management | api-management | Impl |
| IA.MI.5 | Identity and Access Management | Support user-assigned managed identity for least-privilege roles | user-assigned-identity | Impl |
| IA.AAD.1 | Identity and Access Management | Enable Azure AD login extension on Linux VMs | vm | Impl |
| IA.AAD.2 | Identity and Access Management | Enable Azure AD login extension on Windows VMs | vm-windows | Impl |
| IA.AAD.3 | Identity and Access Management | Configure Azure AD administrator on SQL Server | sql | Impl |
| IA.AK.1 | Identity and Access Management | Protect secrets using Azure Key Vault; RBAC only (no access policies) | keyvault | Impl |
| IA.AK.2 | Identity and Access Management | Store secrets in Key Vault; no plain text in repo (use TF_VAR or KV reference) | key-vault-secret | Partial |
| IA.AK.3 | Identity and Access Management | Enable soft delete and purge protection on Key Vault | keyvault | Impl |
| IA.AK.4 | Identity and Access Management | Disable public network access on Key Vault when using private endpoint | keyvault | Impl |
| IA.AKS.1 | Identity and Access Management | Enable Azure AD integration and Azure RBAC on AKS | aks | Impl |
| DP.BP.1 | Data Protection | Enforce HTTPS only on Storage Account | storage-account | Impl |
| DP.BP.2 | Data Protection | Enforce minimum TLS 1.2 on Storage Account | storage-account | Impl |
| DP.BP.3 | Data Protection | Disable public network access on Storage when using private endpoint | storage-account | Impl |
| DP.BP.4 | Data Protection | Enable blob versioning for critical data | storage-account | Impl |
| DP.BP.5 | Data Protection | Configure blob/container soft delete retention | storage-account | Impl |
| DP.SQL.1 | Data Protection | Enforce minimum TLS 1.2 on SQL Server | sql | Impl |
| DP.SQL.2 | Data Protection | Restrict SQL firewall rules; no 0.0.0.0/0 in prod | sql | Impl |
| DP.SQL.3 | Data Protection | Configure short-term retention for SQL Database backup | sql | Impl |
| DP.RD.1 | Data Protection | Disable non-SSL port and enforce TLS 1.2 on Redis Cache | redis | Impl |
| DP.APP.1 | Data Protection | Enforce HTTPS only and minimum TLS 1.2 on App Service / Web App | app-service | Impl |
| DP.APP.2 | Data Protection | Disable FTPS on App Service / Web App | app-service | Impl |
| DP.FN.1 | Data Protection | Enforce HTTPS only, FTPS disabled, TLS 1.2 on Function App | function-app | Impl |
| DP.VM.1 | Data Protection | Support encryption at host on VMs | vm, vm-windows | Impl |
| DP.VM.2 | Data Protection | Support Secure Boot and vTPM on VMs | vm, vm-windows | Impl |
| DP.ACR.1 | Data Protection | Disable admin user on Container Registry; use managed identity or AAD | registry | Impl |
| DP.MYSQL.1 | Data Protection | Restrict MySQL firewall rules; use TF_VAR for administrator password | mysql-flexible | Partial |
| DP.MYSQL.2 | Data Protection | Configure backup retention and geo-redundant backup on MySQL Flexible | mysql-flexible | Impl |
| DP.RSV.1 | Data Protection | Enable soft delete on Recovery Services Vault | recovery-services-vault | Impl |
| LM.BP.1 | Logging and Monitoring | Centralized logging via Log Analytics Workspace | log-analytics | Impl |
| LM.BP.2 | Logging and Monitoring | Configure log retention per compliance (e.g. 90–365 days) | log-analytics | Impl |
| LM.BP.3 | Logging and Monitoring | Application performance monitoring via Application Insights | application-insights | Impl |
| LM.BP.4 | Logging and Monitoring | Link Application Insights to Log Analytics for unified retention | application-insights | Impl |
| LM.VM.1 | Logging and Monitoring | Support boot diagnostics on VMs | vm, vm-windows | Impl |
| LM.DIAG.1 | Logging and Monitoring | Diagnostic settings to Log Analytics (resource-level) | N/A (no module) | N/A |
| BC.BP.1 | Backup and Recovery | Enable soft delete on Recovery Services Vault | recovery-services-vault | Impl |
| BC.BP.2 | Backup and Recovery | Apply delete lock on Recovery Services Vault in prod | recovery-services-vault | Impl |
| BC.SQL.1 | Backup and Recovery | Short-term retention for SQL Database | sql | Impl |
| BC.SA.1 | Backup and Recovery | Blob/container soft delete retention on Storage | storage-account | Impl |
| BC.MYSQL.1 | Backup and Recovery | Backup retention and geo-redundant backup on MySQL Flexible | mysql-flexible | Impl |
| SE.BP.1 | Security Operations | No public IP on VMs unless jump box | vm, vm-windows | Impl |
| SE.BP.2 | Security Operations | Use private endpoints for PaaS where supported (Storage, Key Vault, SQL, ACR, etc.) | private-endpoint | Impl |
| SE.BP.3 | Security Operations | Private DNS zones for private endpoint name resolution | private-dns-zone | Impl |
| SE.KV.1 | Security Operations | Key Vault delete lock (optional) | keyvault | Impl |
| SE.SA.1 | Security Operations | Storage Account delete lock (optional) | storage-account | Impl |
| SE.ACR.1 | Security Operations | Disable public network access on ACR when using private endpoint | registry | Impl |
| AP.BP.1 | App Service Security | HTTPS only, FTPS disabled, TLS 1.2 on Web App | app-service | Impl |
| AP.BP.2 | App Service Security | System-assigned managed identity; use Key Vault references for secrets | app-service | Impl |
| AP.BP.3 | App Service Security | Always On for production Web App | app-service | Impl |
| FN.BP.1 | Function App Security | Runtime version in allowed set (e.g. Node 12/14/16/18/20/22) | function-app | Impl |
| FN.BP.2 | Function App Security | Storage key from Key Vault reference in prod | function-app | Partial |
| LA.BP.1 | Logic App Security | Storage and plan from module; secrets via Key Vault reference | logic-app | Partial |
| AK.BP.1 | AKS Security | Azure AD and Azure RBAC for AKS | aks | Impl |
| AK.BP.2 | AKS Security | Network policy (e.g. azure) for micro-segmentation | aks | Impl |
| AK.BP.3 | AKS Security | Standard load balancer SKU | aks | Impl |
| AK.BP.4 | AKS Security | Node pool in VNet subnet for network isolation | aks | Impl |
| AK.BP.5 | AKS Security | AKS Private Cluster (control plane private) | aks | N/A |
| GV.RG.1 | Governance | Resource group naming and mandatory tags | resource-group | Impl |
| GV.RG.2 | Governance | Resource group delete lock | resource-group | Impl |
| GV.RG.3 | Governance | No resources without tags (common_tags from root) | All modules | Impl |
| NS.VN.1 | Network Security | Virtual network address space and subnets | vnet | Impl |
| NS.VN.2 | Network Security | Optional DNS servers on VNet | vnet | Impl |
| NS.VN.3 | Network Security | Service endpoints on subnets where required | vnet | Impl |
| NS.VN.4 | Network Security | Private endpoint subnet prefix configurable | vnet | Impl |
| IA.KV.1 | Identity and Access Management | Key Vault RBAC authorization enabled | keyvault | Impl |
| IA.KV.2 | Identity and Access Management | Key Vault network ACLs (default action, bypass) | keyvault | Impl |
| DP.SA.1 | Data Protection | Storage account naming (no hyphens per Azure) | storage-account | Impl |
| DP.SA.2 | Data Protection | Storage account replication and tier | storage-account | Impl |
| LM.LA.1 | Logging and Monitoring | Log Analytics Workspace SKU and retention | log-analytics | Impl |
| LM.AI.1 | Logging and Monitoring | Application Insights application type and retention | application-insights | Impl |
| SE.PE.1 | Security Operations | Private endpoint subresource names (blob, vault, sqlServer, etc.) | private-endpoint | Impl |
| SE.PE.2 | Security Operations | Private endpoint private DNS zone ID optional | private-endpoint | Impl |
| AP.AP.1 | API Management Security | API Management managed identity | api-management | Impl |
| AP.AP.2 | API Management Security | API Management VNet integration | api-management | N/A |
| GV.TG.1 | Governance | Naming and mandatory tags on all modules | All modules | Impl |

---

**Summary**

| STATUS | COUNT |
|--------|-------|
| Impl | 91 |
| Partial | 5 |
| N/A | 3 |

*Extend this table with additional CONTROL IDs as per your baseline. Map each to MODULE (this repo’s module name) and STATUS (Impl / Partial / N/A).*
