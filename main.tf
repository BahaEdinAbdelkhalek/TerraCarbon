terraform {
  required_version = ">= 1.7.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "TerraCarbon.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy               = false
      recover_soft_deleted_key_vaults            = true
      purge_soft_deleted_secrets_on_destroy      = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

data "azurerm_client_config" "current" {}

locals {
  name_prefix          = "tc-${var.project_suffix}"
  resource_group_name  = "rg-${local.name_prefix}"
  key_vault_name       = "kv-${local.name_prefix}"
  automation_account_name = "aa-${local.name_prefix}"
  storage_account_name    = "st${replace(local.name_prefix, "-", "")}"
  logic_app_name          = "la-${local.name_prefix}"
  log_analytics_name      = "law-${local.name_prefix}"

  common_tags = var.tags
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  name                = local.log_analytics_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = var.log_retention_days
  tags                = var.tags
  depends_on          = [module.resource_group]
}

module "key_vault" {
  source              = "./modules/key_vault"
  key_vault_name      = local.key_vault_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = data.azurerm_client_config.current.object_id
  allowed_ip_ranges   = var.allowed_ip_ranges

  carbon_threshold_kg          = var.carbon_threshold_kg
  cost_threshold_usd           = var.cost_threshold_usd
  min_carbon_reduction_percent = var.min_carbon_reduction_percent
  cpu_utilization_threshold    = var.cpu_utilization_threshold

  tags       = var.tags
  depends_on = [module.resource_group]
}

module "automation_account" {
  source                  = "./modules/automation_account"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  automation_account_name = local.automation_account_name
  key_vault_id            = module.key_vault.id
  key_vault_name          = module.key_vault.name
  log_analytics_id        = module.log_analytics.id
  subscription_id         = data.azurerm_client_config.current.subscription_id
  tags                    = var.tags
  depends_on              = [module.key_vault, module.log_analytics]
}

module "storage_account" {
  source               = "./modules/storage_account"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  storage_account_name = local.storage_account_name
  tags                 = var.tags
  depends_on           = [module.resource_group]
}

module "logic_app" {
  source                  = "./modules/logic_app"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  logic_app_name          = local.logic_app_name
  automation_account_name = module.automation_account.name
  automation_account_id   = module.automation_account.id
  key_vault_name          = module.key_vault.name
  log_analytics_id        = module.log_analytics.id
  subscription_id         = data.azurerm_client_config.current.subscription_id
  tags                    = var.tags
  depends_on              = [module.automation_account, module.storage_account]
}
