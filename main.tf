# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-test-02"   
  location = "Central India"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-test-02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-test-02"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-test-02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akstest01"

  default_node_pool {
    name            = "system"
    vm_size         = "Standard_DC2ads_v5"
    node_count      = 1
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Dev"
    Project     = "AKS-Test"
  }
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size        = "Standard_DC2ads_v5"
  node_count     = 1
  mode           = "User"
  vnet_subnet_id = azurerm_subnet.aks.id

  tags = {
    Environment = "Dev"
    Project     = "AKS-Test"
  }
}
