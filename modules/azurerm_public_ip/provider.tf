# Provider inherited from root; do not add provider block here (enables count/for_each in root)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
