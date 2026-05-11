# =============================================================================
# Outputs for AKS Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Group Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.aks.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.aks.location
}

# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.aks.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.aks.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet"
  value       = azurerm_subnet.aks.name
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.appgw.id
}

# -----------------------------------------------------------------------------
# AKS Cluster Outputs
# -----------------------------------------------------------------------------
output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_cluster_private_fqdn" {
  description = "Private FQDN of the AKS cluster (if private cluster)"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "aks_node_resource_group" {
  description = "Name of the node resource group"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

# -----------------------------------------------------------------------------
# AKS Credentials (Sensitive)
# -----------------------------------------------------------------------------
output "aks_kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_kube_config_host" {
  description = "Host endpoint for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}

output "aks_kube_config_client_certificate" {
  description = "Client certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "aks_kube_config_client_key" {
  description = "Client key for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "aks_kube_config_cluster_ca_certificate" {
  description = "Cluster CA certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Identity Outputs
# -----------------------------------------------------------------------------
output "aks_identity_principal_id" {
  description = "Principal ID of the AKS cluster identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "aks_identity_client_id" {
  description = "Client ID of the AKS cluster identity"
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "aks_kubelet_identity_principal_id" {
  description = "Principal ID of the kubelet identity"
  value       = azurerm_user_assigned_identity.aks_kubelet.principal_id
}

output "aks_kubelet_identity_client_id" {
  description = "Client ID of the kubelet identity"
  value       = azurerm_user_assigned_identity.aks_kubelet.client_id
}

# -----------------------------------------------------------------------------
# Log Analytics Outputs
# -----------------------------------------------------------------------------
# output "log_analytics_workspace_id" {
#   description = "ID of the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.aks.id
# }

# output "log_analytics_workspace_name" {
#   description = "Name of the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.aks.name
# }

# output "log_analytics_workspace_primary_key" {
#   description = "Primary shared key for the Log Analytics workspace"
#   value       = azurerm_log_analytics_workspace.aks.primary_shared_key
#   sensitive   = true
# }

# -----------------------------------------------------------------------------
# Node Pool Outputs
# -----------------------------------------------------------------------------
output "system_node_pool_name" {
  description = "Name of the system node pool"
  value       = var.system_node_pool_name
}

output "user_node_pool_name" {
  description = "Name of the user node pool"
  value       = azurerm_kubernetes_cluster_node_pool.user.name
}

output "user_node_pool_id" {
  description = "ID of the user node pool"
  value       = azurerm_kubernetes_cluster_node_pool.user.id
}

# -----------------------------------------------------------------------------
# Kubectl Commands
# -----------------------------------------------------------------------------
output "kubectl_config_command" {
  description = "Azure CLI command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "kubectl_config_command_admin" {
  description = "Azure CLI command to configure kubectl with admin credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.aks.name} --admin"
}
