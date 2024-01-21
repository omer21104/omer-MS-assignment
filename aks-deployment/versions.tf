terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.67.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }

  required_version = ">= 0.14"
}
