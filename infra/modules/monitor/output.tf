output "log_workspace_id" {
  value = azurerm_log_analytics_workspace.default.id
}

output "appi_connection_string" {
  value     = azurerm_application_insights.default.connection_string
  sensitive = true
}

output "monitor_private_link_scope_id" {
  value = azurerm_monitor_private_link_scope.default.id

  depends_on = [
    azurerm_monitor_private_link_scoped_service.default,
    azurerm_monitor_private_link_scoped_service.monitor
  ]
}
