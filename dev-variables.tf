variable "resource_group_location" {
  type        = string
  default     = "eastus2"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureuser"
  sensitive   = true
}

variable "password" {
  type       = string
  description = "password "
  default     = "Azure@123456"
  sensitive   = true
  }

variable "size" {
  type = string
  description = "The size of the Virtual Machine."
  default = "Standard_D2as_v4"
}

variable "source_image" {
  type = string
  description = "The source image of the Virtual Machine."
  default = "/subscriptions/12d08a43-87ab-49fc-b06f-d1d31622044a/resourcegroups/Devops_project/providers/Microsoft.Compute/galleries/azure_compute_gallery/images/custom_jenkins_image1/versions/1.0.0"
}

variable "rg_nm" {
  type = string
  description = "The name of the resource group."
  default = "Devops_project_dev"
}

variable "computer_names" {
  type = list(string)
  description = "computer name"
  default = ["Jenkins", "Jenkins1"] 
}
