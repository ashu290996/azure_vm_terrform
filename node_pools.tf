# =============================================================================
# AKS Node Pools
# =============================================================================

# -----------------------------------------------------------------------------
# User Node Pool
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_pool_vm_size
  node_count            = var.user_node_pool_node_count
  min_count             = var.user_node_pool_min_count
  max_count             = var.user_node_pool_max_count
  auto_scaling_enabled  = true
  os_disk_size_gb       = var.user_node_pool_os_disk_size_gb
  os_disk_type          = "Managed"
  max_pods              = var.user_node_pool_max_pods
  mode                  = "User"
  vnet_subnet_id        = azurerm_subnet.aks.id
  zones                 = var.user_node_pool_availability_zones

  # Node Labels
  node_labels = merge(
    var.user_node_pool_node_labels,
    {
      "nodepool-type" = "user"
      "environment"   = var.environment
    }
  )

  # Node Taints (optional)
  node_taints = var.user_node_pool_node_taints

  # Upgrade Settings
  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

# Additional User Node Pool for GPU/Spot Instances (Optional)
# resource "azurerm_kubernetes_cluster_node_pool" "spot" {
#   name                  = "spot"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
#   vm_size               = "Standard_D4s_v3"
#   node_count            = 0
#   min_count             = 0
#   max_count             = 10
#   enable_auto_scaling   = true
#   mode                  = "User"
#   priority              = "Spot"
#   eviction_policy       = "Delete"
#   spot_max_price        = -1  # Pay up to on-demand price
#   vnet_subnet_id        = azurerm_subnet.aks.id
#   zones                 = ["1", "2", "3"]
#
#   node_labels = {
#     "kubernetes.azure.com/scalesetpriority" = "spot"
#   }
#
#   node_taints = [
#     "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
#   ]
#
#   tags = var.tags
# }
