variable "logic_app_name" {
  description = "Name of the Logic App workflow"
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

variable "automation_account_name" {
  description = "Name of the Automation Account to trigger"
  type        = string
}

variable "automation_account_id" {
  description = "Resource ID of the Automation Account"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault (passed to runbook parameters)"
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
  description = "Tags to apply to the Logic App"
  type        = map(string)
  default     = {}
}
