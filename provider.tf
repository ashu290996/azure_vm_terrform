terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
backend  "azurerm" {
  resource_group_name   = "azure-terraform-rg"
  storage_account_name  = "remotebackened"
  container_name        = "tfstate"
  key                   = "terraform.tfstate"
}
}


provider "azurerm" {
  features {}

}



