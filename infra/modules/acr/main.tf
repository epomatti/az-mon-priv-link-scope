resource "azurerm_container_registry" "acr" {
  name                = "acr${var.workload_no_dash}"
  resource_group_name = var.group
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
}
