variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}
variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}
