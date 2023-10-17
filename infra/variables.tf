variable "workload" {
  type    = string
  default = "examplefactory"
}

variable "logs_internet_ingestion_enabled" {
  type    = bool
  default = false
}

variable "logs_internet_query_enabled" {
  type    = bool
  default = true
}

variable "appi_internet_ingestion_enabled" {
  type    = bool
  default = false
}

variable "appi_internet_query_enabled" {
  type    = bool
  default = true
}

variable "webapp_vnet_route_all_enabled" {
  type    = bool
  default = false
}

variable "webapp_service_plan_sku_name" {
  type    = string
  default = "B1"
}
