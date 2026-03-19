# =============================================================================
# Remote backend for Terraform state (uncomment and set for team/CI use)
# =============================================================================
terraform {
backend "azurerm" {
  resource_group_name  = "rg-tf-backend"
  storage_account_name = "tfstatepankaj123"
  container_name       = "tfstate"
  key                  = "infra.tfstate"
}
}
