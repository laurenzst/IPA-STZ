#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⠙⢿⣿⣿⠟⠉⠄⣿⣿⠄⢀⣀⣀⣀⡀⠙⣿
#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⢠⡀⠙⠋⢀⡄⠄⣿⣿⠄⠈⠉⠉⠉⠁⠄⣿
#   ⣧⠄⠙⠻⠿⠛⠁⣠⣿⣿⠄⢸⣿⣦⣴⣿⡇⠄⣿⣿⠄⠘⠛⠛⠛⠛⠄⣼
#   ⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣶⣾⣿⣿⣿⣿⣷⣶⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿
#   ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄


#   Date:          2023.04.17
#   Creator:       Laurenz Ströbele, laurenz.stroebele@umb.ch | Team Linux Operations UMB AG
#   Filename:      main.tf
#   Description:   Main File to create Resources for Azure K8s Automation
#   Contains:
#     - Terraform settings
#     - Providers: azurerm
#     - Azure Resource Group
#     - Virtual Network
#     - Subnet
#     - Network Security Group

##############################################################################################

# Terraform Providers
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

# Terraform Providers
provider "azurerm" {
  features {}

  subscription_id = var.azureSubscription
  tenant_id       = var.azureTenant
}

# Create a Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.cShortName}-${var.azregion}-${var.servicename}-${var.rgAddition}"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.azregion}-core-connectivity"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "snet" {
  name                 = "snet-cluster"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group and rule 
resource "azurerm_network_security_group" "nsg" {
  name                = "${azurerm_virtual_network.vnet.name}-${azurerm_subnet.snet.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
        environment = "K8s Security Group"
    }
}