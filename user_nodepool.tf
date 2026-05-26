# =============================================================================
# Additional User Node Pool (user1)
# =============================================================================

resource "azurerm_kubernetes_cluster_node_pool" "user1" {
  name                  = var.user_node_pool_name1
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
  orchestrator_version    = var.kubernetes_version

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