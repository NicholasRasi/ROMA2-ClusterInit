terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "=2.88.1"
    }
  }
}
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.rg_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "main" {
  name                = var.network_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

