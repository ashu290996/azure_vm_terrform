# =============================================================================
# Route Tables for AKS Network
# =============================================================================

# Route Table (for custom routing if needed)
resource "azurerm_route_table" "aks" {
  name                          = "rt-aks-${var.project_name}-${var.environment}"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  bgp_route_propagation_enabled = true
  tags                          = var.tags
}

# Associate Route Table with AKS Subnet
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}
