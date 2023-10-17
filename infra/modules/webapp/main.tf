resource "azurerm_container_registry" "acr" {
  name                = "acr${var.workload}"
  resource_group_name = var.group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_service_plan" "default" {
  name                = "plan-${var.workload}"
  resource_group_name = var.group
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku_name
}

resource "azurerm_linux_web_app" "default" {
  name                = "app-${var.workload}999"
  resource_group_name = var.group
  location            = var.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  site_config {
    always_on         = true
    health_check_path = "/actuator/health"

    vnet_route_all_enabled = var.web_app_vnet_route_all_enabled

    application_stack {
      docker_image_name        = "javaapp:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
    DOCKER_ENABLE_CI                      = true
    WEBSITES_PORT                         = 8080
  }

  lifecycle {
    ignore_changes = [virtual_network_subnet_id]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "default" {
  app_service_id = azurerm_linux_web_app.default.id
  subnet_id      = var.app_subnet_id
}

resource "azurerm_monitor_diagnostic_setting" "plan" {
  name                       = "Plan Diagnostics"
  target_resource_id         = azurerm_service_plan.default.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "Application Diagnostics"
  target_resource_id         = azurerm_linux_web_app.default.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
