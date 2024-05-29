variable "workload" {
  type = string
}

variable "group" {
  type = string
}

variable "location" {
  type = string
}

variable "service_plan_sku_name" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "web_app_vnet_route_all_enabled" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "application_insights_connection_string" {
  type      = string
  sensitive = true
}

variable "acr_login_server" {
  type = string
}

variable "acr_admin_username" {
  type = string
}

variable "acr_admin_password" {
  type      = string
  sensitive = true
}
