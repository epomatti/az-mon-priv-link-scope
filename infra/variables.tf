variable "workload" {
  type    = string
  default = "epicservicex"
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  type    = bool
  default = false
}

variable "appi_internet_ingestion_enabled" {
  type    = bool
  default = false
}

variable "webapp_vnet_route_all_enabled" {
  type    = bool
  default = false
}
