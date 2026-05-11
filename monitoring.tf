# # =============================================================================
# # Monitoring Infrastructure for AKS Cluster
# # =============================================================================

# # -----------------------------------------------------------------------------
# # Log Analytics Workspace
# # -----------------------------------------------------------------------------
# resource "azurerm_log_analytics_workspace" "aks" {
#   name                = "law-${var.project_name}-${var.environment}"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name
#   sku                 = var.log_analytics_sku
#   retention_in_days   = var.log_analytics_retention_days
#   tags                = var.tags

#   # Enable for daily cap if needed (in GB)
#   # daily_quota_gb = 5
# }

# # -----------------------------------------------------------------------------
# # Log Analytics Solutions
# # -----------------------------------------------------------------------------

# # Container Insights Solution
# resource "azurerm_log_analytics_solution" "container_insights" {
#   solution_name         = "ContainerInsights"
#   location              = azurerm_resource_group.aks.location
#   resource_group_name   = azurerm_resource_group.aks.name
#   workspace_resource_id = azurerm_log_analytics_workspace.aks.id
#   workspace_name        = azurerm_log_analytics_workspace.aks.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }

#   tags = var.tags
# }

# # -----------------------------------------------------------------------------
# # Diagnostic Settings for AKS (created after AKS cluster)
# # -----------------------------------------------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "aks" {
#   name                       = "diag-${var.project_name}-${var.environment}"
#   target_resource_id         = azurerm_kubernetes_cluster.aks.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

#   # Kubernetes API Server Logs
#   enabled_log {
#     category = "kube-apiserver"
#   }

#   # Kubernetes Audit Logs
#   enabled_log {
#     category = "kube-audit"
#   }

#   # Kubernetes Audit Admin Logs
#   enabled_log {
#     category = "kube-audit-admin"
#   }

#   # Kubernetes Controller Manager Logs
#   enabled_log {
#     category = "kube-controller-manager"
#   }

#   # Kubernetes Scheduler Logs
#   enabled_log {
#     category = "kube-scheduler"
#   }

#   # Cluster Autoscaler Logs
#   enabled_log {
#     category = "cluster-autoscaler"
#   }

#   # Guard Logs
#   enabled_log {
#     category = "guard"
#   }

#   # Cloud Controller Manager Logs
#   enabled_log {
#     category = "cloud-controller-manager"
#   }

#   # Metrics
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }

# # -----------------------------------------------------------------------------
# # Action Group for Alerts (Optional)
# # -----------------------------------------------------------------------------
# resource "azurerm_monitor_action_group" "aks_alerts" {
#   name                = "ag-aks-${var.project_name}-${var.environment}"
#   resource_group_name = azurerm_resource_group.aks.name
#   short_name          = "aksalerts"
#   tags                = var.tags

#   # Email notification - uncomment and update
#   # email_receiver {
#   #   name                    = "admin"
#   #   email_address           = "admin@example.com"
#   #   use_common_alert_schema = true
#   # }

#   # Webhook - uncomment and update
#   # webhook_receiver {
#   #   name        = "slack-webhook"
#   #   service_uri = "https://hooks.slack.com/services/xxx/yyy/zzz"
#   # }
# }

# # -----------------------------------------------------------------------------
# # Metric Alerts for AKS
# # -----------------------------------------------------------------------------

# # Node CPU Alert
# resource "azurerm_monitor_metric_alert" "node_cpu" {
#   name                = "alert-node-cpu-${var.project_name}-${var.environment}"
#   resource_group_name = azurerm_resource_group.aks.name
#   scopes              = [azurerm_kubernetes_cluster.aks.id]
#   description         = "Alert when node CPU exceeds 80%"
#   severity            = 2
#   frequency           = "PT5M"
#   window_size         = "PT15M"
#   tags                = var.tags

#   criteria {
#     metric_namespace = "Microsoft.ContainerService/managedClusters"
#     metric_name      = "node_cpu_usage_percentage"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 80
#   }

#   action {
#     action_group_id = azurerm_monitor_action_group.aks_alerts.id
#   }
# }

# # Node Memory Alert
# resource "azurerm_monitor_metric_alert" "node_memory" {
#   name                = "alert-node-memory-${var.project_name}-${var.environment}"
#   resource_group_name = azurerm_resource_group.aks.name
#   scopes              = [azurerm_kubernetes_cluster.aks.id]
#   description         = "Alert when node memory exceeds 80%"
#   severity            = 2
#   frequency           = "PT5M"
#   window_size         = "PT15M"
#   tags                = var.tags

#   criteria {
#     metric_namespace = "Microsoft.ContainerService/managedClusters"
#     metric_name      = "node_memory_working_set_percentage"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 80
#   }

#   action {
#     action_group_id = azurerm_monitor_action_group.aks_alerts.id
#   }
# }

# # Pending Pods Alert
# resource "azurerm_monitor_metric_alert" "pending_pods" {
#   name                = "alert-pending-pods-${var.project_name}-${var.environment}"
#   resource_group_name = azurerm_resource_group.aks.name
#   scopes              = [azurerm_kubernetes_cluster.aks.id]
#   description         = "Alert when there are pending pods"
#   severity            = 2
#   frequency           = "PT5M"
#   window_size         = "PT15M"
#   tags                = var.tags

#   criteria {
#     metric_namespace = "Microsoft.ContainerService/managedClusters"
#     metric_name      = "kube_pod_status_phase"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 0

#     dimension {
#       name     = "phase"
#       operator = "Include"
#       values   = ["Pending"]
#     }
#   }

#   action {
#     action_group_id = azurerm_monitor_action_group.aks_alerts.id
#   }
# }
