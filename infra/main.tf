terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  affix = "epicservicex"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.affix}"
  location = "brazilsouth"
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_private_link_scope" "default" {
  name                = "ampls-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_monitor_private_link_scoped_service" "default" {
  name                = "amplsservice-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  scope_name          = azurerm_monitor_private_link_scope.default.name
  linked_resource_id  = azurerm_application_insights.default.id
}

resource "azurerm_application_insights" "default" {
  name                = "appi-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workspace_id        = azurerm_log_analytics_workspace.default.id
  application_type    = "other"
}

resource "azurerm_service_plan" "default" {
  name                = "plan-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_linux_web_app" "default" {
  name                = "app-${local.affix}999"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  site_config {
    always_on         = true
    health_check_path = "/actuator/health"

    application_stack {
      docker_image_name        = "javaapp:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.default.connection_string
    DOCKER_ENABLE_CI                      = true
    WEBSITES_PORT                         = 8080
  }
}

# resource "azurerm_app_service_virtual_network_swift_connection" "default" {
#   app_service_id = azurerm_linux_web_app.default.id
#   subnet_id      = azurerm_subnet.app.id
# }

resource "azurerm_monitor_diagnostic_setting" "plan" {
  name                       = "Plan Diagnostics"
  target_resource_id         = azurerm_service_plan.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "Application Diagnostics"
  target_resource_id         = azurerm_linux_web_app.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id

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
