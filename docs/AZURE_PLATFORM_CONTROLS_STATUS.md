# Azure Platform Controls – Implementation Status

Implementation status of Azure platform controls in the same format: **Control ID**, **Status**, **Description / Remarks**, **Implemented using (Link)**, **Reference**, **Comments**.

| Control ID | Status | Description / Remarks | Implemented using (Link) | Reference | Comments |
|------------|--------|----------------------|--------------------------|-----------|----------|
| AZ-PA-1 | Implemented | Resource Group – naming, tags, delete lock | Terraform | modules/resource-group | |
| AZ-PA-2 | Implemented | Virtual Network (VNet) – address space, subnets | Terraform | modules/vnet | |
| AZ-PA-3 | Implemented | Subnet – address prefix, service endpoints | Terraform | modules/vnet | |
| AZ-PA-4 | Implemented | Network Security Group (NSG) – attached to subnets | Terraform | modules/vnet | |
| AZ-PA-5 | Implemented | NSG rules – explicit allow, no 0.0.0.0/0 for management ports (configurable) | Terraform | modules/vnet, tfvars jump_*_source_cidr | |
| AZ-PA-6 | Implemented | Private endpoint subnet – network policies disabled | Terraform | modules/vnet | |
| AZ-PA-7 | Implemented | Private DNS zone – zone and VNet links | Terraform | modules/private-dns-zone | |
| AZ-PA-8 | Implemented | Private Endpoint – subnet, resource, optional private DNS zone group | Terraform | modules/private-endpoint | |
| AZ-PA-9 | Implemented | Public IP – Standard SKU, static | Terraform | modules/azurerm_public_ip | |
| AZ-PA-10 | Implemented | Azure Bastion Host – dedicated subnet, public IP | Terraform | modules/bastion | |
| AZ-PA-11 | Not Implemented | Application Gateway | — | — | No module in repo |
| AZ-PA-12 | Not Implemented | Web Application Firewall (WAF) Policy | — | — | No module in repo |
| AZ-PA-13 | Not Implemented | Azure Firewall | — | — | No module in repo |
| AZ-PA-14 | Not Implemented | Load Balancer | — | — | No module in repo |
| AZ-PA-15 | Not Implemented | Azure Front Door | — | — | No module in repo |
| AZ-PA-16 | Not Implemented | Azure DNS (public) zone | — | — | Private DNS only |
| AZ-PA-17 | Not Implemented | DDoS Protection Standard | — | — | Enable via portal or separate TF |
| AZ-PA-18 | Implemented | Linux Virtual Machine – NIC, OS disk, managed identity, AAD login | Terraform | modules/vm | |
| AZ-PA-19 | Implemented | Windows Virtual Machine – NIC, OS disk, managed identity, AAD login | Terraform | modules/vm-windows | |
| AZ-PA-20 | Implemented | App Service Plan – Linux/Windows, SKU | Terraform | modules/app-service | |
| AZ-PA-21 | Implemented | Linux Web App – HTTPS, TLS, FTPS disabled, identity | Terraform | modules/app-service | |
| AZ-PA-22 | Implemented | Windows Web App – HTTPS, TLS, FTPS disabled, identity | Terraform | modules/app-service | |
| AZ-PA-23 | Implemented | Azure Container Registry (ACR) – admin disabled, network rules | Terraform | modules/registry | |
| AZ-PA-24 | Implemented | Azure Kubernetes Service (AKS) – node pool, Azure RBAC, network profile | Terraform | modules/aks | |
| AZ-PA-25 | Partially Implemented | AKS Private Cluster | — | — | private_cluster_enabled not in module |
| AZ-PA-26 | Implemented | Azure Functions (Function App) – Linux/Windows, TLS, storage | Terraform | modules/function-app | |
| AZ-PA-27 | Implemented | Azure Logic Apps (Standard) – storage, plan | Terraform | modules/logic-app | |
| AZ-PA-28 | Not Implemented | Azure Spring Cloud | — | — | No module in repo |
| AZ-PA-29 | Not Implemented | Azure Red Hat OpenShift | — | — | No module in repo |
| AZ-PA-30 | Implemented | Storage Account – HTTPS only, TLS 1.2, replication | Terraform | modules/storage-account | |
| AZ-PA-31 | Implemented | Storage Account – blob container, soft delete (configurable) | Terraform | modules/storage-account | |
| AZ-PA-32 | Implemented | Key Vault – RBAC, soft delete, purge protection, network ACLs | Terraform | modules/keyvault | |
| AZ-PA-33 | Implemented | Key Vault Secret | Terraform | modules/key-vault-secret | |
| AZ-PA-34 | Implemented | Azure SQL Server – TLS, firewall, Azure AD admin | Terraform | modules/sql | |
| AZ-PA-35 | Implemented | Azure SQL Database – retention, SKU | Terraform | modules/sql | |
| AZ-PA-36 | Not Implemented | Azure Cosmos DB | — | — | No module in repo |
| AZ-PA-37 | Not Implemented | Azure Data Lake Storage | — | — | No module in repo |
| AZ-PA-38 | Not Implemented | Azure Data Factory | — | — | No module in repo |
| AZ-PA-39 | Not Implemented | Azure Databricks | — | — | No module in repo |
| AZ-PA-40 | Implemented | Azure Database for MySQL Flexible Server | Terraform | modules/mysql-flexible | |
| AZ-PA-41 | Implemented | Azure Cache for Redis – TLS, non-SSL disabled | Terraform | modules/redis | |
| AZ-PA-42 | Implemented | Log Analytics Workspace – retention | Terraform | modules/log-analytics | |
| AZ-PA-43 | Implemented | Application Insights | Terraform | modules/application-insights | |
| AZ-PA-44 | Implemented | API Management Service | Terraform | modules/api-management | |
| AZ-PA-45 | Implemented | Recovery Services Vault – soft delete, lock | Terraform | modules/recovery-services-vault | |
| AZ-PA-46 | Implemented | User-Assigned Managed Identity | Terraform | modules/user-assigned-identity | |
| AZ-PA-47 | Implemented | NAT Gateway | Terraform | modules/nat-gateway | |
| AZ-PA-48 | Not Implemented | Azure Policy (assignment/definition) | — | — | No module in repo |
| AZ-PA-49 | Not Implemented | Diagnostic Settings to Log Analytics | — | — | No module in repo |
| AZ-PA-50 | Not Implemented | Azure Backup (Backup Vault, policy) | — | — | RSV only; no backup policy |

*Extend this table with additional Control IDs (AZ-PA-51 onward) as per your full baseline list. Status: Implemented | Partially Implemented | Not Implemented | N/A.*
