variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
  validation {
    condition     = contains(["westeurope", "northeurope", "uksouth", "ukwest", "eastus", "westus2"], var.location)
    error_message = "Location must be a supported Azure region."
  }
}

variable "project_suffix" {
  description = "Short unique suffix appended to all resource names to ensure global uniqueness (3-6 lowercase alphanumeric chars)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,6}$", var.project_suffix))
    error_message = "project_suffix must be 3-6 lowercase alphanumeric characters."
  }
}

variable "tags" {
  description = "Tags applied to every resource in the project"
  type        = map(string)
  default = {
    project     = "TerraCarbon"
    environment = "production"
    managed-by  = "terraform"
  }
}

variable "allowed_ip_ranges" {
  description = "IP CIDRs allowed to access the Key Vault (e.g. CI/CD runner IPs, VPN egress)"
  type        = list(string)
  default     = []
}

variable "carbon_threshold_kg" {
  description = "Carbon emissions threshold in kg CO2e per month — stored in Key Vault"
  type        = string
  default     = "100"
}

variable "cost_threshold_usd" {
  description = "Monthly cost threshold in USD — stored in Key Vault"
  type        = string
  default     = "500"
}

variable "min_carbon_reduction_percent" {
  description = "Minimum carbon reduction % to trigger optimization actions — stored in Key Vault"
  type        = string
  default     = "10"
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization % below which a VM is considered over-provisioned — stored in Key Vault"
  type        = string
  default     = "20"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days (min 30, max 730)"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}
