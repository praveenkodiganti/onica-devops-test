resource "azurerm_virtual_network" "onica-vnet" {
  name                = "onica-azure-network"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "onica-private-subnet" {
  name                 = "onica-azure-private-subnet"
  resource_group_name  = azurerm_resource_group.onica-rg.name
  virtual_network_name = azurerm_virtual_network.onica-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "onica-nsg" {
  name                = "onica-azure-instance-nsg"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
