resource "azurerm_private_dns_zone" "monitor" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone" "oms" {
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone" "ods" {
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone" "agentsvc" {
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor" {
  name                  = "ampls-monitor-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms" {
  name                  = "ampls-oms-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods" {
  name                  = "ampls-ods-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc" {
  name                  = "ampls-agentsvc-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "ampls-blob-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}


resource "azurerm_private_endpoint" "ampls" {
  name                = "peampls-${var.workload}"
  location            = var.location
  resource_group_name = var.group
  subnet_id           = var.ampls_subnet_id

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
    private_connection_resource_id = var.monitor_private_link_scope_id
    is_manual_connection           = false
    subresource_names              = ["azuremonitor"]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.agentsvc,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.monitor,
    azurerm_private_dns_zone_virtual_network_link.ods,
    azurerm_private_dns_zone_virtual_network_link.oms
  ]
}
