# =============================================================================
# Managed Identities for AKS Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# AKS Cluster User Assigned Managed Identity
# -----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# AKS Kubelet/Node Pool User Assigned Managed Identity
# -----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "aks_kubelet" {
  name                = "id-aks-kubelet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Role Assignments for AKS Identity
# -----------------------------------------------------------------------------

# Network Contributor on VNet (required for Azure CNI)
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_virtual_network.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Network Contributor on AKS Subnet
resource "azurerm_role_assignment" "aks_subnet_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Network Contributor on Route Table
resource "azurerm_role_assignment" "aks_route_table_contributor" {
  scope                = azurerm_route_table.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Managed Identity Operator (AKS identity can manage kubelet identity)
resource "azurerm_role_assignment" "aks_identity_operator" {
  scope                = azurerm_user_assigned_identity.aks_kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# -----------------------------------------------------------------------------
# Role Assignments for Kubelet Identity
# -----------------------------------------------------------------------------

# AcrPull permission for Kubelet Identity (if using ACR)
# Uncomment and update the scope when you have an ACR
# resource "azurerm_role_assignment" "aks_kubelet_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.aks_kubelet.principal_id
# }

# -----------------------------------------------------------------------------
# Azure Container Registry (Optional - Uncomment if needed)
# -----------------------------------------------------------------------------
# resource "azurerm_container_registry" "acr" {
#   name                = "acr${var.project_name}${var.environment}"
#   resource_group_name = azurerm_resource_group.aks.name
#   location            = azurerm_resource_group.aks.location
#   sku                 = "Standard"
#   admin_enabled       = false
#   tags                = var.tags
# }

# # Role assignment for AKS to pull from ACR
# resource "azurerm_role_assignment" "aks_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.aks_kubelet.principal_id
# }
