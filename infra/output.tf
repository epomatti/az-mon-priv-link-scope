# output "vm_public_ip" {
#   value = azurerm_public_ip.main.ip_address
# }

output "appservice_default_hostname" {
  value = azurerm_linux_web_app.default.default_hostname
}
