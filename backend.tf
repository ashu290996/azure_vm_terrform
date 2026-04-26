terraform {
  backend "azurerm" {
    resource_group_name  = "azure-terraform-rg"
    storage_account_name = "remotebackened"
    container_name       = "tfstate"
    key                  = "aks-cluster-dev.tfstate"
  }
}
