# =============================================================================
# AKS Cluster Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "rg-${var.project_name}-${var.environment}-nodes"

  # SKU Tier (Free or Standard for SLA)
  sku_tier = var.sku_tier

  # Private Cluster Configuration
  private_cluster_enabled = var.private_cluster_enabled

  # Automatic Upgrades
  automatic_upgrade_channel = var.automatic_channel_upgrade

  # Azure Policy
  azure_policy_enabled = var.azure_policy_enabled

  # Disable Local Accounts (require Azure AD)
  local_account_disabled = var.local_account_disabled

  # Tags
  tags = var.tags

  # -----------------------------------------------------------------------------
  # Identity Configuration
  # -----------------------------------------------------------------------------
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet.id
  }

  # -----------------------------------------------------------------------------
  # Default/System Node Pool
  # -----------------------------------------------------------------------------
  default_node_pool {
    name                         = var.system_node_pool_name
    vm_size                      = var.system_node_pool_vm_size
    node_count                   = var.system_node_pool_node_count
    min_count                    = var.system_node_pool_min_count
    max_count                    = var.system_node_pool_max_count
    auto_scaling_enabled         = true
    os_disk_size_gb              = var.system_node_pool_os_disk_size_gb
    os_disk_type                 = "Managed"
    max_pods                     = var.system_node_pool_max_pods
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = azurerm_subnet.aks.id
    zones                        = var.system_node_pool_availability_zones
    only_critical_addons_enabled = true  # System node pool - only critical addons

    # Node Labels
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    # Upgrade Settings
    upgrade_settings {
      max_surge = "33%"
    }

    tags = var.tags
  }

  # -----------------------------------------------------------------------------
  # Network Configuration
  # -----------------------------------------------------------------------------
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip

    load_balancer_profile {
      managed_outbound_ip_count = 2
    }
  }

  # -----------------------------------------------------------------------------
  # Azure AD Integration (Optional)
  # -----------------------------------------------------------------------------
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_ad_integration ? [1] : []
    content {
      #managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = var.azure_ad_admin_group_object_ids
    }
  }

  # -----------------------------------------------------------------------------
  # OMS Agent (Container Insights)
  # -----------------------------------------------------------------------------
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
    msi_auth_for_monitoring_enabled = true
  }

  # -----------------------------------------------------------------------------
  # Key Vault Secrets Provider
  # -----------------------------------------------------------------------------
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # -----------------------------------------------------------------------------
  # Maintenance Window
  # -----------------------------------------------------------------------------
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2, 3, 4]
    }
    allowed {
      day   = "Saturday"
      hours = [0, 1, 2, 3, 4]
    }
  }

  # -----------------------------------------------------------------------------
  # Auto Scaler Profile
  # -----------------------------------------------------------------------------
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    empty_bulk_delete_max            = 10
    skip_nodes_with_local_storage    = false
    skip_nodes_with_system_pods      = true
  }

  # Dependencies
  depends_on = [
    azurerm_role_assignment.aks_network_contributor,
    azurerm_role_assignment.aks_subnet_contributor,
    azurerm_role_assignment.aks_identity_operator
  ]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

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

# -----------------------------------------------------------------------------
# Additional User Node Pool for GPU/Spot Instances (Optional)
# -----------------------------------------------------------------------------
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
