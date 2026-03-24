# =============================================================================
# Dev Environment - Sample-ready tfvars (apply without errors)
# Naming: JSR-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload> (see docs/NAMING_CONVENTION.md)
# VMs use vnet_key/subnet_key (subnet_id resolved in root); Web Apps use app_service_plan_key.
# Sample VM passwords (SampleDevPass123!@#) allow apply to succeed; change after first login.
# For production secrets use TF_VAR_* or Key Vault.
# =============================================================================

# -----------------------------------------------------------------------------
# Company-mandatory tags
# -----------------------------------------------------------------------------
created_by       = "Pankaj"
created_date     = "2026-03-19"
environment     = "dev"
requester        = "Application Team"
ticket_reference = "INC-12345"
project_name     = "Banking-App"

# Naming convention: JSR-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload>
name_prefix   = "jsr-004"
project_type  = "INT"
workload      = "Bank-Dev"
location      = "centralindia"

# jump_rdp_source_cidr = "YOUR_IP/32"
# jump_ssh_source_cidr = "YOUR_IP/32"

# =============================================================================
# RESOURCE GROUPS (all arguments)
# =============================================================================
resource_groups = {
  main = {
    name        = "jsr-004-Azure-INT-RG-Bank-Dev"
    location    = "centralindia"
    managed_by  = null
    create_lock = false
    lock_level  = "CanNotDelete"
    tags        = { 
      tag = {
      cost_center = "dev"
      approved_by = "cloud_architect"
    }}
  }
}

# =============================================================================
# VIRTUAL NETWORKS – Subnet-specific NSG rules (one NSG per subnet; rules per subnet for clarity and least-privilege)
#
# Subnet purposes (reference):
#   web     – Web tier: load balancers, web apps; user-facing HTTP/HTTPS traffic. Restrict to HTTPS only.
#   app     – Application tier: app servers, VMs; SSH/RDP for management from VNet or jump only.
#   data    – Data tier: SQL, storage private endpoints; allow only app-tier and required ports (e.g. 1433).
#   bastion – Azure Bastion host; fixed name AzureBastionSubnet, /26; NSG managed by Azure.
#   (PE)    – Private endpoints subnet (snet-privateendpoints): PaaS private links; outbound HTTPS to Azure.
#
# NSG rules purpose: Least-privilege per subnet. Each rule restricts who can reach which port (e.g. data only from app).
# If a subnet omits nsg_rules, vnet-level nsg_rules are used as fallback. See docs/NSG_RULES_SAMPLES.md.
# =============================================================================
vnets = {
  main = {
    name                         = "jsr-004-Azure-INT-VNet-Bank-Dev"
    resource_group_name           = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                     = "centralindia"
    address_space                 = ["10.0.0.0/16"]
    dns_servers                   = []    # Azure Default DNS IP: 168.63.129.16; set custom if needed (e.g. on-prem DNS IPs for hybrid)
    create_nsg                    = true
    nsg_per_subnet                = true
    create_private_endpoint_subnet = true
    private_endpoint_subnet_prefix = "10.0.254.0/24"
    subnets = {
      # -------------------------------------------------------------------------
      # Web tier: user-facing traffic. NSG allows only HTTPS (443); no HTTP for security.
      # -------------------------------------------------------------------------
      web = {
        name                   = "snet-web"
        address_prefixes       = ["10.0.1.0/24"]
        allow_private_endpoint  = false
        service_endpoints       = []
        delegation             = null   # Assigns subnet to a specific Azure service (e.g. Microsoft.Web/serverFarms for App Service); set to null if no delegation needed.
        nsg_rules = {
          # Purpose: Allow only encrypted web traffic. Add allow_http (80) only if you need HTTP redirect or legacy.
          allow_https = {
            name                        = "AllowHTTPS"
            priority                    = 100
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_range      = "443"
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
            source_address_prefixes     = []
            destination_address_prefixes = []
            description                 = "Web tier: HTTPS only"
          }
        }
      }
      # -------------------------------------------------------------------------
      # App tier: application servers, VMs. NSG allows SSH/RDP only from VNet (no direct internet).
      # -------------------------------------------------------------------------
      app = {
        name             = "snet-app"
        address_prefixes  = ["10.0.2.0/24"]
        allow_private_endpoint = false
        service_endpoints = []
        delegation       = null
        nsg_rules = {
          # Purpose: Admin access (SSH/RDP) only from within VNet (e.g. via Bastion or jump); blocks internet.
          allow_ssh = {
            name                        = "AllowSSH"
            priority                    = 100
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_range      = "22"
            source_address_prefix       = "VirtualNetwork"
            destination_address_prefix  = "*"
            source_address_prefixes     = []
            destination_address_prefixes = []
            description                 = "App tier: SSH from VNet"
          }
          allow_rdp = {
            name                        = "AllowRDP"
            priority                    = 110
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_range      = "3389"
            source_address_prefix       = "VirtualNetwork"
            destination_address_prefix  = "*"
            source_address_prefixes     = []
            destination_address_prefixes = []
            description                 = "App tier: RDP from VNet"
          }
        }
      }
      # -------------------------------------------------------------------------
      # Data tier: databases, private endpoints. NSG allows only app subnet to reach data (e.g. SQL 1433).
      # -------------------------------------------------------------------------
      data = {
        name             = "snet-data"
        address_prefixes  = ["10.0.3.0/24"]
        allow_private_endpoint = false
        service_endpoints = []
        delegation       = null
        nsg_rules = {
          # Purpose: SQL Server access only from app tier (10.0.2.0/24); no web or internet.
          allow_sql_from_app = {
            name                        = "AllowSQLFromApp"
            priority                    = 100
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_range      = "1433"
            source_address_prefix       = "10.0.2.0/24"
            destination_address_prefix  = "*"
            source_address_prefixes     = []
            destination_address_prefixes = []
            description                 = "Data tier: SQL from app subnet only"
          }
        }
      }
      # -------------------------------------------------------------------------
      # Bastion: Azure Bastion host for secure RDP/SSH. Must be named AzureBastionSubnet, /26.
      # NSG: not managed here (Azure requires specific rules); subnet excluded from per-subnet NSG in module.
      # -------------------------------------------------------------------------
      bastion = {
        name                   = "AzureBastionSubnet"
        address_prefixes       = ["10.0.5.0/26"]
        allow_private_endpoint = false
        service_endpoints     = []
        delegation            = null
      }
    }
    # Fallback when a subnet has no nsg_rules (not used when all subnets define their own, as above)
    nsg_rules = {}
    # -------------------------------------------------------------------------
    # Private endpoint subnet (snet-privateendpoints): used by PaaS Private Link.
    # NSG purpose: allow outbound HTTPS to Azure so private endpoints can resolve and connect.
    # -------------------------------------------------------------------------
    pe_subnet_nsg_rules = {
      allow_https_out = {
        name                        = "AllowHttpsOutbound"
        priority                    = 100
        direction                   = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "443"
        source_address_prefix        = "*"
        destination_address_prefix   = "AzureCloud"
        source_address_prefixes     = []
        destination_address_prefixes = []
        description                 = "Allow HTTPS to Azure for Private Link"
      }
    }
    tags = {}
  }
}

# =============================================================================
# PUBLIC IPs (all arguments)
# =============================================================================
public_ips = {
  bastion = {
    name                 = "jsr-004-Azure-INT-PIP-Bastion-Dev"
    resource_group_name   = "jsr-004-Azure-INT-RG-Bank-Dev"
    location              = "centralindia"
    allocation_method     = "Static"
    sku                   = "Standard"
    sku_tier              = "Regional"
    zones                 = []
    ip_version            = "IPv4"
    domain_name_label    = null
    domain_name_label_scope = null
    ddos_protection_mode = "VirtualNetworkInherited"
    ddos_protection_plan_id = null
    edge_zone            = null
    idle_timeout_in_minutes = 4
    ip_tags              = {}
    public_ip_prefix_id  = null
    reverse_fqdn         = null
    tags                 = {}
  }
}

# =============================================================================
# STORAGE ACCOUNTS (all arguments)
# =============================================================================
storage_accounts = {
  main = {
    name                                 = "jsr002azureintstobankdev"
    resource_group_name                  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                             = "centralindia"
    account_tier                         = "Standard"
    account_replication_type              = "LRS"
    account_kind                         = "StorageV2"
    access_tier                          = "Hot"
    enable_https_traffic_only            = true
    min_tls_version                      = "TLS1_2"
    allow_nested_items_to_be_public      = false
    public_network_access_enabled        = false
    shared_access_key_enabled            = false # Entra ID (RBAC) only; set true if shared key access needed (e.g. legacy tools)
    # Optional: customer-managed key (CMK) encryption; create key in Key Vault and grant storage identity Key Vault Crypto User
    # customer_managed_key = {
    #   key_vault_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/MJSRosoft.KeyVault/vaults/<vault-name>"
    #   key_name     = "<key-name>"
    #   # key_version = ""                # optional; omit for latest
    #   # user_assigned_identity_id = null  # omit to use storage system-assigned identity
    # }
    network_rules                        = null
    blob_soft_delete_retention_days     = 7
    container_soft_delete_retention_days  = 7
    enable_blob_versioning               = false
    last_access_time_enabled             = false
    create_delete_lock                   = false
    lock_level                           = "CanNotDelete"
    containers = {
      data = { name = "data", access_type = "private", metadata = {} }
    }
    tags = {}
  }
  # Logic App Standard requires a storage account with shared_access_key_enabled = true (provider does not support identity-only).
  logicapp = {
    name                                 = "jsr002intlogicappdev" # max 24 chars
    resource_group_name                  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                             = "centralindia"
    account_tier                         = "Standard"
    account_replication_type             = "LRS"
    account_kind                         = "StorageV2"
    access_tier                          = "Hot"
    enable_https_traffic_only            = true
    min_tls_version                      = "TLS1_2"
    allow_nested_items_to_be_public      = false
    public_network_access_enabled       = true
    shared_access_key_enabled            = true
    network_rules                        = null
    blob_soft_delete_retention_days      = 7
    container_soft_delete_retention_days = 7
    enable_blob_versioning               = false
    last_access_time_enabled             = false
    create_delete_lock                   = false
    lock_level                           = "CanNotDelete"
    containers                           = {}
    tags                                 = {}
  }
}

# =============================================================================
# KEY VAULTS (all arguments)
# =============================================================================
key_vaults = {
  main = {
    name                          = "jsr-004-INT-KV-BankDev"
    resource_group_name           = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                      = "centralindia"
    sku_name                      = "standard"
    enabled_for_disk_encryption  = false
    enabled_for_deployment       = false
    enabled_for_template_deployment = false
    enable_rbac_authorization    = true
    soft_delete_retention_days   = 30
    purge_protection_enabled    = true
    public_network_access_enabled = false
    network_acls = {
      default_action             = "Deny"
      bypass                     = "AzureServices"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
    create_delete_lock = false
    lock_level         = "CanNotDelete"
    tags = {}
  }
}

key_vault_secrets = {}

# =============================================================================
# SQL SERVERS (Entra ID preferred: set azuread_administrator with azuread_authentication_only = true and omit login/password)
# =============================================================================
sql_servers = {
  main = {
    name                           = "jsr-004-azure-int-sql-bank-dev"
    resource_group_name            = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                       = "centralindia"
    version                        = "12.0"
    administrator_login            = "sqladmin"
    administrator_login_password   = "SampleDevSqlPass123!@#"
    minimum_tls_version            = "1.2"
    public_network_access_enabled  = false # false = private-only (use private endpoint/VNet); set true only if public login required
    azuread_administrator          = null # For Entra-only: set login_username, object_id, azuread_authentication_only = true; omit administrator_login/password
    firewall_rules = {
      allow_azure = {
        name             = "AllowAzureServices"
        start_ip_address  = "0.0.0.0"
        end_ip_address    = "0.0.0.0"
      }
    }
    databases = {
      appdb = {
        name                     = "appdb"
        collation                = "SQL_Latin1_General_CP1_CI_AS"
        license_type              = "LicenseIncluded"
        max_size_gb               = 2
        sku_name                  = "S0"
        short_term_retention_days = 7
        long_term_retention_policy = null
        tags                      = {}
      }
    }
    tags = {}
  }
}

# =============================================================================
# PRIVATE DNS ZONES (vnet_links use vnet_key; root resolves to vnet_id)
# =============================================================================
private_dns_zones = {
  blob = {
    name                = "privatelink.blob.core.windows.net"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    vnet_links = {
      main = {
        vnet_key            = "main"
        registration_enabled = false
      }
    }
    tags = {}
  }
  vault = {
    name                = "privatelink.vaultcore.azure.net"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    vnet_links = {
      main = {
        vnet_key            = "main"
        registration_enabled = false
      }
    }
    tags = {}
  }
}

# =============================================================================
# PRIVATE ENDPOINTS (vnet_key + target_type + target_key; root resolves subnet_id + resource_id)
# =============================================================================
private_endpoints = {
  storage_blob = {
    name                 = "jsr-004-pe-storage-blob-dev"
    resource_group_name   = "jsr-004-Azure-INT-RG-Bank-Dev"
    location              = "centralindia"
    vnet_key              = "main"
    target_type           = "storage_account"
    target_key            = "main"
    subresource_names     = ["blob"]
    private_dns_zone_id   = null
    private_dns_zone_group_name = "default"
    tags                  = {}
  }
  keyvault = {
    name                 = "jsr-004-pe-kv-dev"
    resource_group_name   = "jsr-004-Azure-INT-RG-Bank-Dev"
    location              = "centralindia"
    vnet_key              = "main"
    target_type           = "key_vault"
    target_key            = "main"
    subresource_names     = ["vault"]
    private_dns_zone_id   = null
    private_dns_zone_group_name = "default"
    tags                  = {}
  }
}

# =============================================================================
# CONTAINER REGISTRIES (all arguments; retention_policy/trust_policy not in module)
# =============================================================================
registries = {
  main = {
    name                         = "JSR002azureintacrbankdev"
    resource_group_name          = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                     = "centralindia"
    sku                          = "Standard"
    admin_enabled                = false
    public_network_access_enabled = true
    quarantine_policy_enabled    = false
    anonymous_pull_enabled        = false
    data_endpoint_enabled         = false
    network_rule_bypass_option   = "AzureServices"
    network_rule_set             = null
    encryption                   = null
    tags                         = {}
  }
}

# =============================================================================
# BASTION HOSTS (vnet_key + subnet_key + public_ip_key; root resolves subnet_id + public_ip_id)
# =============================================================================
bastion_hosts = {
  main = {
    name                   = "jsr-004-Azure-INT-Bastion-Bank-Dev"
    resource_group_name     = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                = "centralindia"
    vnet_key                = "main"
    subnet_key              = "bastion"
    public_ip_key           = "bastion"
    copy_paste_enabled      = true
    file_copy_enabled       = false
    ip_connect_enabled      = true
    scale_units             = 2
    shareable_link_enabled  = false
    tunneling_enabled       = false
    tags                    = {}
  }
}

# =============================================================================
# NAT GATEWAYS (all arguments)
# =============================================================================
nat_gateways = {
  main = {
    name                    = "jsr-004-Azure-INT-NAT-Bank-Dev"
    resource_group_name     = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                = "centralindia"
    idle_timeout_in_minutes = 4
    sku_name                = "Standard"
    zones                   = []
    tags                    = {}
  }
}

# =============================================================================
# USER-ASSIGNED MANAGED IDENTITIES (all arguments)
# =============================================================================
user_assigned_identities = {
  app = {
    name                = "jsr-004-Azure-INT-UAI-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    tags                = {}
  }
}

# =============================================================================
# MYSQL FLEXIBLE SERVERS (Entra ID first: omit administrator_login/password; set when using MySQL auth)
# =============================================================================
# MySQL Flexible Server – if you see ProvisionNotSupportedForRegion, set location to a supported region (e.g. eastus, westus2); see https://aka.ms/mysqlcapacity
# =============================================================================
mysql_servers = {
  main = {
    name                          = "jsr-004-azure-int-mysql-bank-dev"
    resource_group_name           = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                      = "centralindia" # use e.g. "eastus" if centralindia is not supported for MySQL Flexible in your subscription
    administrator_login           = "mysqladmin"
    administrator_password        = "SampleDevMysqlPass123!@#" # optional for Entra ID–first; use TF_VAR in prod
    sku_name                      = "GP_Standard_D2ds_v4"
    version                       = "8.0.21"
    storage_gb                    = 20
    zone                          = null
    backup_retention_days          = 7
    geo_redundant_backup_enabled  = false
    public_network_access_enabled = true
    delegated_subnet_id           = null
    private_dns_zone_id           = null
    firewall_rules = {
      allow_azure = {
        name             = "AllowAzure"
        start_ip_address  = "0.0.0.0"
        end_ip_address    = "0.0.0.0"
      }
    }
    tags = {}
  }
}

# =============================================================================
# REDIS (all arguments)
# =============================================================================
redis_caches = {
  main = {
    name                         = "jsr-004-Azure-INT-Redis-Bank-Dev"
    resource_group_name          = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                     = "centralindia"
    sku_name                     = "Basic"
    family                       = "C"
    capacity                     = 0
    enable_non_ssl_port          = false
    minimum_tls_version          = "1.2"
    public_network_access_enabled = true
    redis_configuration          = {}
    subnet_id                    = null
    private_static_ip_address    = null
    zones                        = []
    tags                         = {}
  }
}

# =============================================================================
# LOG ANALYTICS (all arguments)
# =============================================================================
log_analytics_workspaces = {
  main = {
    name                = "jsr-004-Azure-INT-LAW-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    sku                 = "PerGB2018"
    retention_in_days   = 30
    daily_quota_gb      = null
    tags                = {}
  }
}

# =============================================================================
# APPLICATION INSIGHTS (all arguments)
# =============================================================================
app_insights = {
  main = {
    name                = "jsr-004-Azure-INT-AppInsights-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    application_type    = "web"
    workspace_id        = null
    retention_in_days   = 90
    sampling_percentage = null
    tags                = {}
  }
}

# =============================================================================
# APP SERVICE PLANS (all arguments)
# =============================================================================
app_service_plans = {
  main = {
    name                = "jsr-004-Azure-INT-App-Srv-Plan-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    os_type             = "Linux"
    sku_name            = "B1"
    tags                = {}
  }
  logicapp = {
    name                = "jsr-004-Azure-INT-Plan-LogicApp-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    os_type             = "Linux"
    sku_name            = "WS1"   # Workflow Standard tier (WS1, WS2, WS3); required for Logic App Standard
    tags                = {}
  }
}

# =============================================================================
# WEB APPS - app_service_plan_key references plan "main"; resolved in app-service module (no ID needed)
# =============================================================================
web_apps = {
  sample = {
    name                 = "jsr-004-Azure-INT-Web-App-Bank-Dev"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location             = "centralindia"
    app_service_plan_key = "main"
    os_type              = "Linux"
    https_only           = true
    ftps_state           = "Disabled"
    minimum_tls_version  = "1.2"
    always_on            = true
    app_settings         = { "WEBSITE_RUN_FROM_PACKAGE" = "" }
    connection_string    = []
    identity_type        = "SystemAssigned"
    identity_ids         = []
    tags                 = {}
  }
}

# =============================================================================
# FUNCTION APPS (storage_account_key + app_service_plan_key; root resolves name, key, plan_id)
# =============================================================================
function_apps = {
  sample = {
    name                       = "jsr-004-Azure-INT-Func-Bank-Dev"
    resource_group_name         = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                   = "centralindia"
    storage_account_key        = "main"
    app_service_plan_key       = "main"
    os_type                    = "Linux"
    version                    = "~4"
    node_version               = "18" # Node.js runtime: "12", "14", "16", "18", "20", "22"
    https_only                 = true
    ftps_state                 = "Disabled"
    minimum_tls_version        = "1.2"
    app_settings               = {}
    identity_type              = "SystemAssigned"
    identity_ids               = []
    # create_storage_rbac = false  # set to false if Terraform runner lacks User Access Administrator; assign storage roles manually
    tags                       = {}
  }
}

# =============================================================================
# LOGIC APPS (storage_account_key + app_service_plan_key; root resolves)
# Logic App Standard requires storage with shared_access_key_enabled = true; use storage key "logicapp" (dedicated account with key enabled).
# =============================================================================
logic_apps = {
  sample = {
    name                 = "jsr-004-Azure-INT-Logic-App-Bank-Dev"
    resource_group_name   = "jsr-004-Azure-INT-RG-Bank-Dev"
    location              = "centralindia"
    storage_account_key   = "logicapp"
    app_service_plan_key  = "logicapp"   # must be WorkflowStandard plan (not main)
    tags                  = {}
  }
}

# =============================================================================
# API MANAGEMENT (all arguments)
# =============================================================================
api_managements = {
  main = {
    name                         = "jsr-004-Azure-INT-APIM-Bank-Dev"
    resource_group_name          = "jsr-004-Azure-INT-RG-Bank-Dev"
    location                     = "centralindia"
    publisher_name               = "Banking Team"
    publisher_email              = "team@company.com"
    sku_name                     = "Developer_1"
    subnet_id                    = null
    public_network_access_enabled = true
    identity_type                = "SystemAssigned"
    identity_ids                 = []
    tags                         = {}
  }
}

# =============================================================================
# AKS CLUSTERS (default_node_pool.vnet_key + subnet_key optional; root resolves vnet_subnet_id)
# =============================================================================
aks_clusters = {
  main = {
    name                = "jsr-004-Azure-INT-AKS-Bank-Dev"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location             = "centralindia"
    dns_prefix           = "JSR002aks"
    default_node_pool = {
      name                = "default"
      vm_size             = "Standard_B2s_v2" # use _v2; Standard_B2s often not allowed per subscription/region
      node_count          = 1
      enable_auto_scaling = false
      min_count           = null
      max_count           = null
      vnet_key            = "main"
      subnet_key          = "app"
    }
    identity_type         = "SystemAssigned"
    identity_ids          = []
    enable_azure_rbac     = true
    admin_group_object_ids = []
    # service_cidr must not share first octet with VNet (this VNet is 10.0.0.0/16 → use 172.x). If your VNet is 172.16.0.0/16, use the alternative below.
    network_profile = {
      network_plugin    = "azure"
      network_policy    = "azure"
      load_balancer_sku = "standard"
      service_cidr      = "172.16.0.0/16"
      dns_service_ip    = "172.16.0.10"
      # If VNet is 172.16.0.0/16, use this instead to avoid overlap:
      # service_cidr   = "10.0.0.0/16"
      # dns_service_ip = "10.0.0.10"
    }
    tags = {}
  }
}

# =============================================================================
# RECOVERY SERVICES VAULT (all arguments)
# =============================================================================
recovery_services_vaults = {
  main = {
    name                = "jsr-004-Azure-INT-RSV-Bank-Dev"
    resource_group_name = "jsr-004-Azure-INT-RG-Bank-Dev"
    location            = "centralindia"
    sku                 = "Standard"
    soft_delete_enabled = true
    create_lock         = false
    lock_level          = "CanNotDelete"
    tags                = {}
  }
}

# =============================================================================
# LINUX VMs - vnet_key + subnet_key resolve to subnet_id (root uses module.vnet output).
# Sample uses password auth so apply succeeds without SSH key; change password after first login.
# =============================================================================
vms = {
  sample = {
    name                 = "jsr-004-Azure-LIN-INT-VM-Bank-Dev"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location             = "centralindia"
    size                 = "Standard_B2s"
    vnet_key             = "main"
    subnet_key           = "app"
    admin_username       = "azureuser"
    admin_password      = "SampleDevPass123!@#"
    disable_password_authentication = false
    admin_ssh_key        = []
    create_public_ip     = false
    private_ip_address   = null
    nsg_id               = null
    accelerated_networking = false
    os_disk = {
      caching                   = "ReadWrite"
      storage_account_type      = "Premium_LRS"
      disk_size_gb              = null
      write_accelerator_enabled = false
    }
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }
    encryption_at_host_enabled = false
    secure_boot_enabled       = true
    vtpm_enabled              = true
    boot_diagnostics          = {}
    identity_type             = "SystemAssigned"
    identity_ids              = []
    availability_zone         = null
    availability_set_id       = null
    enable_aad_login_extension = true
    custom_data               = null
    computer_name             = null
    tags                      = {}
  }
}

# =============================================================================
# WINDOWS VMs - vnet_key + subnet_key resolve to subnet_id in root.
# Sample password meets Azure complexity; change after first login or use TF_VAR in prod.
# =============================================================================
windows_vms = {
  sample = {
    name                 = "jsr-004-Azure-WIN-INT-VM-Bank-Dev"
    resource_group_name  = "jsr-004-Azure-INT-RG-Bank-Dev"
    location             = "centralindia"
    size                 = "Standard_B2s"
    vnet_key             = "main"
    subnet_key           = "app"
    admin_username      = "azureuser"
    admin_password      = "SampleDevPass123!@#"
    create_public_ip     = false
    private_ip_address   = null
    nsg_id               = null
    accelerated_networking = false
    os_disk = {
      name                   = null
      caching                = "ReadWrite"
      storage_account_type   = "Premium_LRS"
      disk_size_gb           = null
      write_accelerator_enabled = false
    }
    source_image_reference = {
      publisher = "MJSRosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-azure-edition"
      version   = "latest"
    }
    encryption_at_host_enabled = false
    secure_boot_enabled        = true
    vtpm_enabled               = true
    boot_diagnostics           = {}
    identity_type              = "SystemAssigned"
    identity_ids               = []
    availability_zone          = null
    availability_set_id        = null
    enable_automatic_updates   = true
    patch_mode                 = "AutomaticByOS"
    hotpatching_enabled        = false
    timezone                   = "UTC"
    license_type               = "None"
    winrm_listeners            = []
    enable_aad_login_extension = true
    custom_data                = null
    computer_name              = null
    tags                       = {}
  }
}

# =============================================================================
# ROLE ASSIGNMENTS (optional) – grant users/groups Entra ID access to resources
# Replace principal_id with the Entra ID object ID of the user or group (from Azure Portal > Entra ID > Users/Groups).
# scope_key must match the logical key of the resource (e.g. main = storage_accounts.main, sample = vms.sample).
# =============================================================================
role_assignments = {
  # Example: grant a user read access to the storage account (uncomment and set principal_id)
  storage_reader = {
    scope_type           = "storage_account"
    scope_key            = "main"
    role_definition_name = "Storage Blob Data Reader"
    principal_id         = "00000000-0000-0000-0000-000000000000" # Replace with user/group object ID
    principal_type       = "User"
    description          = "Read blob access for user"
  }

  # Example: grant Key Vault Secrets User (read secrets)
  kv_secrets_user = {
    scope_type           = "key_vault"
    scope_key            = "main"
    role_definition_name = "Key Vault Secrets User"
    principal_id         = "00000000-0000-0000-0000-000000000000"
    description          = "Read secrets for app or user"
  }

  # Example: grant SQL DB Contributor (manage database)
  sql_db_contributor = {
    scope_type           = "sql_server"
    scope_key            = "main"
    role_definition_name = "SQL DB Contributor"
    principal_id         = "00000000-0000-0000-0000-000000000000"
    description          = "Database access for user/group"
  }

  # Example: grant Linux VM Administrator Login (SSH with Entra ID)
  linux_vm_admin = {
    scope_type           = "linux_vm"
    scope_key            = "sample"
    role_definition_name = "Virtual Machine Administrator Login"
    principal_id         = "00000000-0000-0000-0000-000000000000"
    description          = "SSH login to Linux VM via Entra ID"
  }

  # Example: grant Windows VM Administrator Login (RDP with Entra ID)
  windows_vm_admin = {
    scope_type           = "windows_vm"
    scope_key            = "sample"
    role_definition_name = "Virtual Machine Administrator Login"
    principal_id         = "00000000-0000-0000-0000-000000000000"
    description          = "RDP login to Windows VM via Entra ID"
  }

  # Example: grant Reader on entire resource group
  rg_reader = {
    scope_type           = "resource_group"
    scope_key            = "main"
    role_definition_name = "Reader"
    principal_id         = "00000000-0000-0000-0000-000000000000"
    description          = "Read access to resource group"
  }
}

additional_tags = {}





