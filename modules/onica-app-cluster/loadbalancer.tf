resource "azurerm_lb" "onica-azure-lb" {
  name                = "onica-azure-loadbalancer"
  sku                 = "Standard"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.onica-public-ip.id
  }
}

resource "azurerm_public_ip" "onica-public-ip" {
  name                = "onica-azure-public-ip"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.onica-rg.name
  sku                 = "Standard"
}


resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.onica-rg.name
  loadbalancer_id     = azurerm_lb.onica-azure-lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.onica-rg.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.onica-azure-lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "onica-lb-probe" {
  resource_group_name = azurerm_resource_group.onica-rg.name
  loadbalancer_id     = azurerm_lb.onica-azure-lb.id
  name                = "onica-http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "onica-lb-rule" {
  resource_group_name            = azurerm_resource_group.onica-rg.name
  loadbalancer_id                = azurerm_lb.onica-azure-lb.id
  name                           = "OnicaLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.onica-lb-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
}
