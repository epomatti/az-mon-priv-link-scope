### Monitor Endpoints ###
resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${var.workload}"
  location            = var.location
  resource_group_name = var.group
  sku                 = "PerGB2018"
  retention_in_days   = 30

  internet_ingestion_enabled = var.logs_internet_ingestion_enabled
  internet_query_enabled     = var.logs_internet_query_enabled
}

resource "azurerm_application_insights" "default" {
  name                = "appi-${var.workload}"
  location            = var.location
  resource_group_name = var.group
  workspace_id        = azurerm_log_analytics_workspace.default.id
  application_type    = "other"

  internet_ingestion_enabled = var.appi_internet_ingestion_enabled
  internet_query_enabled     = var.appi_internet_query_enabled
}

### AMPLS ###
resource "azurerm_monitor_private_link_scope" "default" {
  name                = "ampls-${var.workload}"
  resource_group_name = var.group
}

resource "azurerm_monitor_private_link_scoped_service" "default" {
  name                = "amplsservice-${var.workload}"
  resource_group_name = var.group
  scope_name          = azurerm_monitor_private_link_scope.default.name
  linked_resource_id  = azurerm_application_insights.default.id
}

resource "azurerm_monitor_private_link_scoped_service" "monitor" {
  name                = "amplsmonitor-${var.workload}"
  resource_group_name = var.group
  scope_name          = azurerm_monitor_private_link_scope.default.name
  linked_resource_id  = azurerm_log_analytics_workspace.default.id
}
