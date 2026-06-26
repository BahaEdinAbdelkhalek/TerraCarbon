variable "automation_account_name" {
  description = "Name of the Automation Account"
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

variable "key_vault_id" {
  description = "Resource ID of the Key Vault"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault (passed to runbook as parameter)"
  type        = string
}

variable "log_analytics_id" {
  description = "Resource ID of the Log Analytics workspace"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
