variable "name" {
  description = "Log Analytics workspace name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "retention_in_days" {
  description = "Data retention period in days (30–730)"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
