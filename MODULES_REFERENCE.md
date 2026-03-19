# Module Reference – No Duplicates

Canonical modules used by **environments/dev** and **environments/prod**:

| Purpose           | Canonical module path               | Used by root |
|-------------------|-------------------------------------|--------------|
| Resource group    | `modules/resource-group`            | Yes          |
| VNet/subnets      | `modules/vnet`                     | Yes          |
| Public IP         | `modules/azurerm_public_ip`        | Yes          |
| Linux VM          | `modules/vm`                       | Yes          |
| Windows VM        | `modules/vm-windows`               | Yes          |
| Storage account   | `modules/storage-account`          | Yes          |
| Key Vault         | `modules/keyvault`                 | Yes          |
| Key Vault secret  | `modules/key-vault-secret`        | Yes          |
| SQL server+db     | `modules/sql`                      | Yes          |
| Private DNS       | `modules/private-dns-zone`         | Yes          |
| Private endpoint  | `modules/private-endpoint`        | Yes          |
| ACR               | `modules/registry`                 | Yes          |
| Bastion           | `modules/bastion`                  | Yes          |
| NAT Gateway       | `modules/nat-gateway`              | Yes          |
| User-assigned identity | `modules/user-assigned-identity` | Yes          |
| MySQL Flexible    | `modules/mysql-flexible`           | Yes          |
| Redis             | `modules/redis`                    | Yes          |
| Log Analytics     | `modules/log-analytics`            | Yes          |
| Application Insights | `modules/application-insights`  | Yes          |
| App Service + Web App | `modules/app-service`         | Yes          |
| Function App      | `modules/function-app`             | Yes          |
| Logic App         | `modules/logic-app`               | Yes          |
| API Management    | `modules/api-management`          | Yes          |
| AKS               | `modules/aks`                     | Yes          |
| Recovery Services Vault | `modules/recovery-services-vault` | Yes   |

**Removed (duplicate/orphaned):**  
`azurerm_resource_group`, `azurerm_networking`, `azurerm_key_vault`, `azurerm_sql_server`, `azurerm_sql_database`, `azurerm_compute` — same functionality as the canonical modules above; root did not reference them.
