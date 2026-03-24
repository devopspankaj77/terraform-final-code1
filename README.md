



git init
git checkout -b feature/initial-setup
git add .
git commit -m "Initial commit"

git remote add origin https://bitbucket.org/icreontech/unified-dashboard.git
git pull origin main --rebase   # safer than unrelated histories

git push -u origin feature/initial-setup






# Introduction 
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project.

**Naming convention:** Resource names follow `ICR-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload>`. See [docs/NAMING_CONVENTION.md](docs/NAMING_CONVENTION.md) for Internal/Client examples (VM, Web App, Plan, etc.) and resource type abbreviations.

**Entra ID (Azure AD) access:** Prefer Entra ID for storage, SQL, MySQL, and VMs; username/password and shared keys are optional. See [docs/ENTRA_ID_ACCESS.md](docs/ENTRA_ID_ACCESS.md).

**User/group access and role assignments:** Step-by-step guide for granting access to every resource type (Storage, Key Vault, SQL, VMs, AKS, App Service, etc.) and how users connect. See [docs/ACCESS_AND_ROLE_ASSIGNMENTS.md](docs/ACCESS_AND_ROLE_ASSIGNMENTS.md).

**Customer-managed key (CMK) encryption:** Storage accounts support optional encryption with a key from Key Vault. See [docs/CMK_ENCRYPTION.md](docs/CMK_ENCRYPTION.md).

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests.

# Troubleshooting

**ResourceGroupNotFound (404)** when running `terraform apply` on a new environment or after changing the resource group name (e.g. `srm-003-Azure-INT-RG-Bank-Dev`): Azure can return "resource group could not be found" for child resources if they are created in parallel with the resource group, due to propagation delay. The root module sets `depends_on = [module.resource_group]` on all modules that create resources in that RG. If you still see 404s, run `terraform apply` again once the RG exists, or use `terraform apply -parallelism=5`.

**MySQL Flexible – ProvisionNotSupportedForRegion**: Your subscription or the chosen region may not support Azure Database for MySQL Flexible Server. Use a supported region for the MySQL server (e.g. `eastus`, `westus2`, `westeurope`). In `tfvars`, set `location` inside `mysql_servers.<key>` to a [supported region](https://aka.ms/mysqlcapacity) (you can keep the rest of the env in another region).

**SQL – DenyPublicEndpointEnabled / firewall rules**: When `public_network_access_enabled = false`, Azure does not allow creating or modifying firewall rules. The SQL module only creates firewall rules when `public_network_access_enabled` is true; ensure your tfvars do not define `firewall_rules` for servers with public access disabled, or the module will skip them automatically.

**Storage – KeyBasedAuthenticationNotPermitted / Missing Resource Identity**: When a storage account has `shared_access_key_enabled = false`, the provider must use Azure AD for data plane operations. The dev/prod `provider.tf` sets `storage_use_azuread = true` for this. Ensure the identity running Terraform has at least *Storage Blob Data Contributor* (or equivalent) on the storage account if you use data plane resources (e.g. containers) with key auth disabled.

**Azure Bastion – NetworkSecurityGroupNotCompliantForAzureBastionSubnet**: Azure Bastion requires a specific NSG rule set on its subnet. The VNet module does not attach a per-subnet NSG to the subnet named `AzureBastionSubnet`. **Bastion – ip_connect_enabled**: Supported only when `sku` is `Standard` or `Premium`; the Bastion module defaults `sku` to `Standard` and only sets `ip_connect_enabled` when sku allows it.

**Logic App – server farm cannot contain Logic Apps**: Logic App Standard must use an App Service Plan with **sku_name = "WS1"** (or WS2, WS3 – Workflow Standard tier), not B1, P1v2, etc. The sample tfvars include a dedicated plan **`logicapp`** with `sku_name = "WS1"`; set **`logic_apps.*.app_service_plan_key = "logicapp"`**. Logic App also requires storage with `shared_access_key_enabled = true`; use **`storage_account_key = "logicapp"`** (dedicated storage account).

**Role assignment 403 (AuthorizationFailed, roleAssignments/write)**: The identity running Terraform needs permission to create role assignments (e.g. *User Access Administrator* or *Owner* on the subscription or resource group). Grant the required role, or set **`create_storage_rbac = false`** on each Function App in tfvars so Terraform does not create the storage role assignments; then assign **Storage Blob/Queue/Table Data Contributor** to the Function App’s managed identity manually in the Portal.

**AKS – ServiceCidrOverlapExistingSubnetsCidr**: A **CIDR cross-check is enabled before implementation**: the root module runs `check "aks_service_cidr_no_overlap"` at **plan time**, so `terraform plan` will fail (and block `terraform apply`) if AKS `service_cidr` overlaps your VNet/subnets. Always run `terraform plan` before apply. The AKS module defaults `service_cidr` to `172.16.0.0/16` and `dns_service_ip` to `172.16.0.10`; override in tfvars if your VNet uses 172.16.0.0/16.

**AKS – VM size not allowed**: If `Standard_B2s` is not available in your subscription/region, use `Standard_B2s_v2` (or another size from the [region/sku list](https://aka.ms/aks/quotas-skus-regions)) in `aks_clusters.*.default_node_pool.vm_size`.

**VMs – EncryptionAtHost not enabled**: If the subscription does not have *Microsoft.Compute/EncryptionAtHost* enabled, set `encryption_at_host_enabled = false` for the VM in tfvars, or rely on the module default (false). 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)