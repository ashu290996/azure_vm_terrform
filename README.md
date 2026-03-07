# AKS Cluster Terraform Configuration

This Terraform configuration deploys a production-ready Azure Kubernetes Service (AKS) cluster with all required networking, identities, and monitoring components.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Resource Group                                     │
│  rg-{project}-{env}                                                         │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Virtual Network (10.0.0.0/16)                     │   │
│  │                                                                      │   │
│  │  ┌──────────────────────┐  ┌──────────────────┐  ┌───────────────┐ │   │
│  │  │   AKS Subnet         │  │  AppGW Subnet    │  │   PE Subnet   │ │   │
│  │  │   10.0.0.0/20        │  │  10.0.16.0/24    │  │  10.0.17.0/24 │ │   │
│  │  │                      │  │                  │  │               │ │   │
│  │  │  ┌──────────────┐   │  │                  │  │               │ │   │
│  │  │  │ AKS Cluster  │   │  │                  │  │               │ │   │
│  │  │  │              │   │  │                  │  │               │ │   │
│  │  │  │ ┌──────────┐ │   │  │                  │  │               │ │   │
│  │  │  │ │ System   │ │   │  │                  │  │               │ │   │
│  │  │  │ │ NodePool │ │   │  │                  │  │               │ │   │
│  │  │  │ └──────────┘ │   │  │                  │  │               │ │   │
│  │  │  │ ┌──────────┐ │   │  │                  │  │               │ │   │
│  │  │  │ │ User     │ │   │  │                  │  │               │ │   │
│  │  │  │ │ NodePool │ │   │  │                  │  │               │ │   │
│  │  │  │ └──────────┘ │   │  │                  │  │               │ │   │
│  │  │  └──────────────┘   │  │                  │  │               │ │   │
│  │  └──────────────────────┘  └──────────────────┘  └───────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐    │
│  │  Managed Identity  │  │ Kubelet Identity   │  │  Log Analytics     │    │
│  │  (AKS Control)     │  │ (Node Pools)       │  │  Workspace         │    │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Components Created

| Component | Description |
|-----------|-------------|
| Resource Group | Container for all AKS resources |
| Virtual Network | VNet with 3 subnets (AKS, AppGW, Private Endpoints) |
| Network Security Groups | NSGs for AKS and AppGW subnets |
| Route Table | Custom routing for AKS subnet |
| User Assigned Identity (AKS) | Control plane identity |
| User Assigned Identity (Kubelet) | Node pool identity for ACR access |
| Log Analytics Workspace | Monitoring and Container Insights |
| AKS Cluster | Kubernetes cluster with system node pool |
| User Node Pool | Additional node pool for applications |
| Metric Alerts | CPU, Memory, and Pending Pods alerts |

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Terraform** >= 1.5.0 installed
3. **Azure Subscription** with appropriate permissions
4. **Service Principal** or Managed Identity for Terraform

## Quick Start

### 1. Clone and Configure

```bash
cd terraform-aks

# Review and modify terraform.tfvars
code terraform.tfvars
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
# For dev environment
terraform plan -var-file="terraform.tfvars"

# For specific environment
terraform plan -var-file="prod.tfvars"
```

### 4. Apply Configuration

```bash
terraform apply -var-file="terraform.tfvars"
```

### 5. Get AKS Credentials

```bash
# Standard credentials
az aks get-credentials --resource-group rg-myaks-dev --name aks-myaks-dev

# Admin credentials (if local accounts enabled)
az aks get-credentials --resource-group rg-myaks-dev --name aks-myaks-dev --admin
```

## Environment Configuration

Create environment-specific tfvars files:

### dev.tfvars
```hcl
environment                 = "dev"
sku_tier                    = "Free"
system_node_pool_node_count = 1
user_node_pool_node_count   = 1
```

### prod.tfvars
```hcl
environment                 = "prod"
sku_tier                    = "Standard"
private_cluster_enabled     = true
local_account_disabled      = true
enable_azure_ad_integration = true
azure_ad_admin_group_object_ids = ["your-aad-group-id"]
```

## Remote State Configuration

For team environments, configure Azure Storage backend:

1. Create storage account:
```bash
az group create --name rg-terraform-state --location eastus
az storage account create --name stterraformstateXXX --resource-group rg-terraform-state --sku Standard_LRS
az storage container create --name tfstate --account-name stterraformstateXXX
```

2. Uncomment backend configuration in `providers.tf`

## Network Planning

| Subnet | CIDR | IPs | Purpose |
|--------|------|-----|---------|
| AKS | 10.0.0.0/20 | 4,096 | Pods and Nodes |
| AppGW | 10.0.16.0/24 | 256 | Application Gateway |
| Private Endpoint | 10.0.17.0/24 | 256 | Private Endpoints |
| Services | 10.1.0.0/16 | 65,536 | Kubernetes Services |

## Node Pool Configuration

### System Node Pool
- Runs critical system components (CoreDNS, metrics-server)
- `only_critical_addons_enabled = true`
- Minimum 2 nodes for HA

### User Node Pool
- Runs application workloads
- Can scale to 0 for cost savings
- Supports custom labels and taints

## Security Features

- ✅ User Assigned Managed Identity (no service principal secrets)
- ✅ Network Policies enabled
- ✅ Azure Policy integration
- ✅ Key Vault Secrets Provider
- ✅ Container Insights enabled
- ✅ Diagnostic logging enabled

## Outputs

After deployment, useful outputs include:

```bash
# View all outputs
terraform output

# Get kubeconfig (sensitive)
terraform output -raw aks_kube_config > ~/.kube/config

# Get kubectl command
terraform output kubectl_config_command
```

## Cleanup

```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars"
```

## Troubleshooting

### Common Issues

1. **Insufficient IP addresses**: Increase subnet size or use Kubenet
2. **Permission errors**: Verify service principal/managed identity permissions
3. **Quota exceeded**: Request quota increase in Azure portal

### Useful Commands

```bash
# Check AKS cluster status
az aks show --resource-group rg-myaks-dev --name aks-myaks-dev --output table

# Check node pool status
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system
```

## References

- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
