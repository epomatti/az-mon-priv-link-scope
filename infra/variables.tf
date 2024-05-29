variable "workload" {
  type = string
}

variable "location" {
  type = string
}

variable "logs_internet_ingestion_enabled" {
  type = bool
}

variable "logs_internet_query_enabled" {
  type = bool
}

variable "appi_internet_ingestion_enabled" {
  type = bool
}

variable "appi_internet_query_enabled" {
  type = bool
}

variable "webapp_vnet_route_all_enabled" {
  type = bool
}

variable "webapp_service_plan_sku_name" {
  type = string
}

variable "acr_sku" {
  type = string
}
