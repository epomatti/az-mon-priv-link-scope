terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

module "vnet" {
  source   = "./modules/vnet"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name
}

module "monitor" {
  source   = "./modules/monitor"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  logs_internet_ingestion_enabled = var.logs_internet_ingestion_enabled
  logs_internet_query_enabled     = var.logs_internet_query_enabled

  appi_internet_ingestion_enabled = var.appi_internet_ingestion_enabled
  appi_internet_query_enabled     = var.appi_internet_query_enabled
}

module "privatelink" {
  source   = "./modules/privatelink"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  vnet_id                       = module.vnet.vnet_id
  ampls_subnet_id               = module.vnet.ampls_subnet_id
  monitor_private_link_scope_id = module.monitor.monitor_private_link_scope_id
}

module "webapp" {
  source   = "./modules/webapp"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  service_plan_sku_name                  = var.webapp_service_plan_sku_name
  app_subnet_id                          = module.vnet.app_subnet_id
  log_analytics_workspace_id             = module.monitor.log_workspace_id
  application_insights_connection_string = module.monitor.appi_connection_string

  web_app_vnet_route_all_enabled = var.webapp_vnet_route_all_enabled
}
