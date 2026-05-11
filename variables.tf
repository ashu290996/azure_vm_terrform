# =============================================================================
# Variable Definitions for AKS Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "Name of the project, used in resource naming"
  type        = string
  default     = "myaks"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "dev"
    Project     = "AKS-Cluster"
  }
}

# -----------------------------------------------------------------------------
# Networking Variables
# -----------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "appgw_subnet_address_prefix" {
  description = "Address prefix for Application Gateway subnet"
  type        = string
  default     = "10.0.16.0/24"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Address prefix for Private Endpoint subnet"
  type        = string
  default     = "10.0.17.0/24"
}

# -----------------------------------------------------------------------------
# AKS Cluster Variables
# -----------------------------------------------------------------------------
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.28.5"
}

variable "sku_tier" {
  description = "SKU tier for AKS (Free or Standard for SLA)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either Free or Standard."
  }
}

variable "private_cluster_enabled" {
  description = "Enable private cluster (private API server)"
  type        = bool
  default     = false
}

variable "automatic_channel_upgrade" {
  description = "Automatic upgrade channel for the cluster"
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["none", "patch", "rapid", "stable", "node-image"], var.automatic_channel_upgrade)
    error_message = "Automatic channel upgrade must be one of: none, patch, rapid, stable, node-image."
  }
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = true
}

variable "network_plugin" {
  description = "Network plugin for AKS (azure or kubenet)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either azure or kubenet."
  }
}

variable "network_policy" {
  description = "Network policy for AKS (azure, calico, or null)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "10.1.0.10"
}

variable "local_account_disabled" {
  description = "Disable local accounts (require Azure AD auth)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# System Node Pool Variables
# -----------------------------------------------------------------------------
variable "system_node_pool_name" {
  description = "Name for the system node pool"
  type        = string
  default     = "system"
}

variable "system_node_pool_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "system_node_pool_node_count" {
  description = "Number of nodes in system node pool"
  type        = number
  default     = 2
}

variable "system_node_pool_min_count" {
  description = "Minimum nodes for system node pool autoscaling"
  type        = number
  default     = 2
}

variable "system_node_pool_max_count" {
  description = "Maximum nodes for system node pool autoscaling"
  type        = number
  default     = 5
}

variable "system_node_pool_os_disk_size_gb" {
  description = "OS disk size for system node pool nodes"
  type        = number
  default     = 128
}

variable "system_node_pool_max_pods" {
  description = "Maximum pods per node in system node pool"
  type        = number
  default     = 50
}

variable "system_node_pool_availability_zones" {
  description = "Availability zones for system node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# -----------------------------------------------------------------------------
# User Node Pool Variables
# -----------------------------------------------------------------------------
variable "user_node_pool_name" {
  description = "Name for the user node pool"
  type        = string
  default     = "userpool"
}

variable "user_node_pool_name1" {
  description = "Name for the user node pool"
  type        = string
  default     = "userpool1"
}

variable "user_node_pool_vm_size" {
  description = "VM size for user node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_pool_node_count" {
  description = "Number of nodes in user node pool"
  type        = number
  default     = 2
}

variable "user_node_pool_min_count" {
  description = "Minimum nodes for user node pool autoscaling"
  type        = number
  default     = 1
}

variable "user_node_pool_max_count" {
  description = "Maximum nodes for user node pool autoscaling"
  type        = number
  default     = 10
}

variable "user_node_pool_os_disk_size_gb" {
  description = "OS disk size for user node pool nodes"
  type        = number
  default     = 128
}

variable "user_node_pool_max_pods" {
  description = "Maximum pods per node in user node pool"
  type        = number
  default     = 50
}

variable "user_node_pool_availability_zones" {
  description = "Availability zones for user node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "user_node_pool_node_labels" {
  description = "Labels for user node pool nodes"
  type        = map(string)
  default = {
    "workload-type" = "user"
  }
}

variable "user_node_pool_node_taints" {
  description = "Taints for user node pool nodes"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Log Analytics Variables
# -----------------------------------------------------------------------------
variable "log_analytics_retention_days" {
  description = "Retention period for Log Analytics workspace in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

# -----------------------------------------------------------------------------
# Azure AD Integration (Optional)
# -----------------------------------------------------------------------------
variable "enable_azure_ad_integration" {
  description = "Enable Azure AD integration for AKS"
  type        = bool
  default     = false
}

variable "azure_ad_admin_group_object_ids" {
  description = "Object IDs of Azure AD groups for cluster admin access"
  type        = list(string)
  default     = []
}
