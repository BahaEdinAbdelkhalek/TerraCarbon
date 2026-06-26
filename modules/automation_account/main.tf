resource "azurerm_automation_account" "this" {
  name                = var.automation_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags


}


resource "azurerm_role_assignment" "cost_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "cost management reader "
  principal_id         = azurerm_automation_account.this.identity

}



resource "azurerm_role_assignment" "vm_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_automation_runbook" "carbon_optimization" {
  name                    = "CarbonOptimizationRunbook"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  description             = "Automated TerraCarbon cost optimization based on emissions data"

  content = file("${path.module}/runbook.ps1")

  tags = var.tags
}

resource "azurerm_automation_schedule" "daily" {
  name                    = "DailyCarbonOptimization"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Day"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2025-01-01T02:00:00Z"
  description             = "Daily carbon optimization analysis at off-peak hours"
}



resource "azurerm_automation_schedule" "peak" {
  name                    = "PeakCarbonOptimization"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Day"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2025-01-01T18:00:00Z"
  description             = "Optimization during peak carbon intensity periods"
}
resource "azurerm_automation_job_schedule" "daily" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azurerm_automation_runbook.carbon_optimization.name
  schedule_name           = azurerm_automation_schedule.daily.name

  parameters = {
    SubscriptionId    = var.subscription_id
    ResourceGroupName = var.resource_group_name
    KeyVaultName      = var.key_vault_name
  }
}
resource "azurerm_automation_job_schedule" "peak" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azurerm_automation_runbook.carbon_optimization.name
  schedule_name           = azurerm_automation_schedule.peak.name

  parameters = {
    SubscriptionId    = var.subscription_id
    ResourceGroupName = var.resource_group_name
    KeyVaultName      = var.key_vault_name
  }
}
