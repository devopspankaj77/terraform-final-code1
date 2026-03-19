# Azure Security Baseline – Implementation Status

Status of the controls from the pasted baseline list. Same format: 項目番号, 分類, 項目名, 現状, 備考.

| 項目番号 | 分類 | 項目名 | 現状 | 備考 |
|----------|------|--------|------|------|
| NS-2000 | Azure セキュリティベースライン | Azure ポリシー | 未対応 | No Azure Policy module in this repo; assign via portal or separate Terraform. |
| NS-2001 | Azure セキュリティベースライン | App Service が Private DNS を使用していること | 一部対応 | Add privatelink.azurewebsites.net zone + VNet link in tfvars when using App Service PE. |
| NS-2002 | Azure セキュリティベースライン | App Service が Private Endpoint を使用していること | 一部対応 | Add private_endpoints entry for web app target when needed; module supports it. |
| NS-2003 | Azure セキュリティベースライン | Azure Kubernetes Service (AKS) が Private Cluster を使用していること | 未対応 | aks module does not set private_cluster_enabled; add to module if required. |
| NS-2004 | Azure セキュリティベースライン | Application Gateway が Private Link を使用していること | 未対応 | No Application Gateway module in this repo. |
| NS-2005 | Azure セキュリティベースライン | Azure Container Registry が Private Endpoint を使用していること | 対応済み | private-endpoint module with target_type/target_key for ACR. |
