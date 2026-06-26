variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique, 3-24 chars)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "key_vault_name must be 3-24 alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Resource group where Key Vault will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID — required by Key Vault"
  type        = string
}

variable "admin_object_id" {
  description = "Object ID of the user/service that gets Secrets Officer role"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP CIDRs allowed through the Key Vault firewall (e.g. your CI/CD runner IPs)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}

variable "carbon_threshold_kg" {
  description = "Carbon emissions threshold in kg CO2e per month"
  type        = string
  default     = "100"
}

variable "cost_threshold_usd" {
  description = "Cost threshold in USD per month"
  type        = string
  default     = "500"
}

variable "min_carbon_reduction_percent" {
  description = "Minimum carbon reduction % to trigger optimization actions"
  type        = string
  default     = "10"
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization % below which a VM is considered over-provisioned"
  type        = string
  default     = "20"
}
