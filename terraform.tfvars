# =============================================================================
# Terraform Variable Values for AKS Cluster
# =============================================================================
# Copy this file and modify values according to your environment
# Example: dev.tfvars, staging.tfvars, prod.tfvars
# =============================================================================

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------
project_name = "myaks"
environment  = "dev"
location     = "eastus"

tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "AKS-Cluster"
  CostCenter  = "IT-Infrastructure"
  Owner       = "DevOps-Team"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
vnet_address_space                     = ["10.0.0.0/16"]
aks_subnet_address_prefix              = "10.0.0.0/20"      # 4096 IPs for AKS
appgw_subnet_address_prefix            = "10.0.16.0/24"     # 256 IPs for App Gateway
private_endpoint_subnet_address_prefix = "10.0.17.0/24"     # 256 IPs for Private Endpoints

# -----------------------------------------------------------------------------
# AKS Cluster Configuration
# -----------------------------------------------------------------------------
kubernetes_version        = "1.28.5"
sku_tier                  = "Standard"        # Standard for SLA, Free for dev
private_cluster_enabled   = false             # Set true for production
automatic_channel_upgrade = "patch"           # none, patch, rapid, stable, node-image
azure_policy_enabled      = true
local_account_disabled    = false             # Set true when using Azure AD

# Network Configuration
network_plugin = "azure"                      # azure (CNI) or kubenet
network_policy = "azure"                      # azure, calico, or null
service_cidr   = "10.1.0.0/16"
dns_service_ip = "10.1.0.10"

# -----------------------------------------------------------------------------
# System Node Pool Configuration
# -----------------------------------------------------------------------------
system_node_pool_name               = "system"
system_node_pool_vm_size            = "Standard_D4s_v3"     # 4 vCPU, 16 GB RAM
system_node_pool_node_count         = 2
system_node_pool_min_count          = 2
system_node_pool_max_count          = 5
system_node_pool_os_disk_size_gb    = 128
system_node_pool_max_pods           = 50
system_node_pool_availability_zones = ["1", "2", "3"]

# -----------------------------------------------------------------------------
# User Node Pool Configuration
# -----------------------------------------------------------------------------
user_node_pool_name               = "userpool"
user_node_pool_vm_size            = "Standard_D4s_v3"       # 4 vCPU, 16 GB RAM
user_node_pool_node_count         = 2
user_node_pool_min_count          = 1
user_node_pool_max_count          = 10
user_node_pool_os_disk_size_gb    = 128
user_node_pool_max_pods           = 50
user_node_pool_availability_zones = ["1", "2", "3"]

user_node_pool_node_labels = {
  "workload-type" = "user"
  "team"          = "application"
}

user_node_pool_node_taints = []
# Example taints:
# user_node_pool_node_taints = [
#   "dedicated=app:NoSchedule"
# ]

# -----------------------------------------------------------------------------
# Log Analytics Configuration
# -----------------------------------------------------------------------------
log_analytics_retention_days = 30
log_analytics_sku            = "PerGB2018"

# -----------------------------------------------------------------------------
# Azure AD Integration (Optional)
# -----------------------------------------------------------------------------
enable_azure_ad_integration     = false
azure_ad_admin_group_object_ids = []
# Example:
# enable_azure_ad_integration     = true
# azure_ad_admin_group_object_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
