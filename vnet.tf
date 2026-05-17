# =============================================================================
# Virtual Network and Subnets for AKS Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.aks_subnet_address_prefix]

  # Required for some Azure services
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]
}

# Application Gateway Subnet (for AGIC)
resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.appgw_subnet_address_prefix]
}

# Private Endpoint Subnet
resource "azurerm_subnet" "private_endpoint" {
  name                 = "snet-pe-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.private_endpoint_subnet_address_prefix]

  private_endpoint_network_policies = "Disabled"
}
