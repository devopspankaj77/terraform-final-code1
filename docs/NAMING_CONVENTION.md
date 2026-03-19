# Naming Convention

All Azure resources follow the pattern:

**`{prefix}-Azure-{INT|CLT}-{ResourceType}-{Workload}`**

- **prefix**: Project/customer code (e.g. `ICR-002`, `ICR-051`).
- **INT**: Internal project.
- **CLT**: Client project.
- **ResourceType**: Short abbreviation for the resource (see table below).
- **Workload**: Application or purpose (e.g. `Bank-Dev`, `Cook-Medical`, `RAT-QA`).

---

## Internal project examples

| Resource     | Example name                          |
|-------------|----------------------------------------|
| Linux VM    | `ICR-002-Azure-LIN-INT-IT-Sonar`       |
| Web App     | `ICR-055-Azure-INT-Web-App-RAT-QA`     |
| App Service Plan | (shared with Web App; see Plan below) |
| Windows VM  | `ICR-002-Azure-WIN-INT-Bank-Dev`       |

---

## Client project examples

| Resource     | Example name                                |
|-------------|----------------------------------------------|
| Web App     | `ICR-051-Azure-CLT-Web-App-Cook-Medical`     |
| Plan        | `ICR-051-Azure-CLT-App-Srv-Plan-Cook-Medical`|
| Windows VM  | `ICR-045-Azure-WIN-CLT-Starting-Point`       |

---

## Resource type abbreviations

| Abbreviation    | Resource                  |
|-----------------|---------------------------|
| RG              | Resource group            |
| VNet            | Virtual network           |
| LIN             | Linux VM                  |
| WIN             | Windows VM                 |
| Web-App         | Web App (App Service)     |
| App-Srv-Plan    | App Service Plan          |
| PIP             | Public IP                 |
| Bastion        | Azure Bastion             |
| NAT             | NAT Gateway               |
| KV              | Key Vault                 |
| SQL             | SQL Server                |
| MySQL           | MySQL Flexible Server     |
| LAW             | Log Analytics Workspace   |
| AppInsights     | Application Insights      |
| APIM            | API Management             |
| AKS             | Kubernetes Service        |
| RSV             | Recovery Services Vault   |
| UAI             | User-Assigned Identity    |
| Func            | Function App              |
| Logic-App       | Logic App                 |

**Storage Account / ACR**: Azure does not allow hyphens. Use lowercase only, e.g. `icr002azureintstobankdev`, `icr002azureintacrbankdev`.

**SQL Server / MySQL Flexible Server**: Azure requires lowercase letters, numbers, and hyphens only. Use e.g. `icr-002-azure-int-sql-bank-dev`, `icr-002-azure-int-mysql-bank-dev`.

---

## Usage in Terraform

- Set **`name_prefix`** in tfvars (e.g. `ICR-002`).
- Set **`project_type`** to `INT` or `CLT`.
- Set **`workload`** for the workload name.
- Build resource names in tfvars as: `"${name_prefix}-Azure-${project_type}-<ResourceType>-<Workload>"` (or use the examples above as templates).
