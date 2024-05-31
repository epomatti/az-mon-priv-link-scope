terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.106.1"
    }
  }
}

resource "random_string" "workload" {
  length  = 5
  special = false
  lower   = true
}

locals {
  affix            = random_string.workload.result
  workload         = "contoso-${local.affix}"
  workload_no_dash = "contoso${local.affix}"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source   = "./modules/vnet"
  workload = local.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name
}

module "monitor" {
  source   = "./modules/monitor"
  workload = local.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  logs_internet_ingestion_enabled = var.logs_internet_ingestion_enabled
  logs_internet_query_enabled     = var.logs_internet_query_enabled

  appi_internet_ingestion_enabled = var.appi_internet_ingestion_enabled
  appi_internet_query_enabled     = var.appi_internet_query_enabled
}

module "privatelink" {
  source   = "./modules/privatelink"
  workload = local.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  vnet_id                       = module.vnet.vnet_id
  ampls_subnet_id               = module.vnet.ampls_subnet_id
  monitor_private_link_scope_id = module.monitor.monitor_private_link_scope_id
}

module "acr" {
  source           = "./modules/acr"
  workload_no_dash = local.workload_no_dash
  location         = azurerm_resource_group.default.location
  group            = azurerm_resource_group.default.name
  sku              = var.acr_sku
}

module "webapp" {
  source   = "./modules/webapp"
  workload = local.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  service_plan_sku_name                  = var.webapp_service_plan_sku_name
  app_subnet_id                          = module.vnet.app_subnet_id
  log_analytics_workspace_id             = module.monitor.log_workspace_id
  application_insights_connection_string = module.monitor.appi_connection_string

  web_app_vnet_route_all_enabled = var.webapp_vnet_route_all_enabled

  acr_login_server   = module.acr.acr_login_server
  acr_admin_username = module.acr.acr_admin_username
  acr_admin_password = module.acr.acr_admin_password
}
