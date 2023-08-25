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

### Network ####

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
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_subnet" "ampls" {
  name                 = "ampls-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.55.0/24"]
}


### Monitor ###

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  internet_ingestion_enabled = var.log_analytics_workspace_internet_ingestion_enabled
  internet_query_enabled     = true
}

resource "azurerm_application_insights" "default" {
  name                = "appi-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workspace_id        = azurerm_log_analytics_workspace.default.id
  application_type    = "other"

  internet_ingestion_enabled = var.appi_internet_ingestion_enabled
  internet_query_enabled     = true
}

### AMPLS ###

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

resource "azurerm_monitor_private_link_scoped_service" "monitor" {
  name                = "amplsmonitor-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  scope_name          = azurerm_monitor_private_link_scope.default.name
  linked_resource_id  = azurerm_log_analytics_workspace.default.id
}

### AMPLS Endpoint ###

resource "azurerm_private_dns_zone" "monitor" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone" "oms" {
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone" "ods" {
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone" "agentsvc" {
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor" {
  name                  = "ampls-monitor-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms" {
  name                  = "ampls-oms-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods" {
  name                  = "ampls-ods-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc" {
  name                  = "ampls-agentsvc-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "ampls-blob-link"
  resource_group_name   = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.default.id
  registration_enabled  = false
}


resource "azurerm_private_endpoint" "ampls" {
  name                = "peampls-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.ampls.id

  private_dns_zone_group {
    name = "ampls-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.monitor.id,
      azurerm_private_dns_zone.oms.id,
      azurerm_private_dns_zone.ods.id,
      azurerm_private_dns_zone.agentsvc.id,
      azurerm_private_dns_zone.blob.id,
    ]
  }

  private_service_connection {
    name                           = "ampls"
    private_connection_resource_id = azurerm_monitor_private_link_scope.default.id
    is_manual_connection           = false
    subresource_names              = ["azuremonitor"]
  }
}

### Web App ###

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

    vnet_route_all_enabled = var.appservice_vnet_route_all_enabled

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

  lifecycle {
    ignore_changes = [virtual_network_subnet_id]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "default" {
  app_service_id = azurerm_linux_web_app.default.id
  subnet_id      = azurerm_subnet.app.id
}

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
