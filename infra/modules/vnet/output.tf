output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "ampls_subnet_id" {
  value = azurerm_subnet.ampls.id
}
