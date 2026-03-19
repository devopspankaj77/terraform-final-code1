terraform {
  # 1.5+ required for check blocks (e.g. AKS service_cidr conflict check). Latest: https://developer.hashicorp.com/terraform/install
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
 #   backend "azurerm" {
#     resource_group_name  = ""
#     storage_account_name = ""
#     container_name       = ""
#     key                  = ""
#   }
}

provider "azurerm" {
  features {}
  subscription_id = "a952c7be-2375-401d-b046-6b79e69b7bf9"
  # Required when any storage account has shared_access_key_enabled = false (Entra ID–only); provider uses Azure AD for data plane checks.
  storage_use_azuread = true
}
