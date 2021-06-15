provider "azurerm" {
  version = "=2.36.0"
  features {}
}

resource "azurerm_resource_group" "onica-rg" {
  name     = "onica-azure-test"
  location = "Canada Central"
}
