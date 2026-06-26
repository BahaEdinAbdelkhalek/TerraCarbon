resource "azurerm_automation_account" "this" {
  name                          = var.automation_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku_name                      = "Basic"
  local_authentication_enabled  = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "automation" {
  name                       = "diag-${var.automation_account_name}"
  target_resource_id         = azurerm_automation_account.this.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "JobLogs"
  }

  enabled_log {
    category = "JobStreams"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}


resource "azurerm_role_assignment" "cost_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Cost Management Reader"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
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

resource "azurerm_role_assignment" "log_analytics_contributor" {
  scope                = var.log_analytics_id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_automation_runbook" "carbon_optimization" {
  name                    = "CarbonOptimizationRunbook"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  runbook_type            = "PowerShell"
  log_verbose             = false
  log_progress            = true
  description             = "Carbon-aware cost optimization: reads thresholds from Key Vault, queries Azure Carbon API, flags over-provisioned resources"

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
  start_time              = timeadd(timestamp(), "24h")
  description             = "Daily carbon optimization analysis at off-peak hours (02:00 UTC)"

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_schedule" "peak" {
  name                    = "PeakCarbonOptimization"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Day"
  interval                = 1
  timezone                = "UTC"
  start_time              = timeadd(timestamp(), "25h")
  description             = "Peak-hour carbon intensity evaluation (18:00 UTC)"

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_job_schedule" "daily" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azurerm_automation_runbook.carbon_optimization.name
  schedule_name           = azurerm_automation_schedule.daily.name

  parameters = {
    subscriptionid    = var.subscription_id
    resourcegroupname = var.resource_group_name
    keyvaultname      = var.key_vault_name
  }
}

resource "azurerm_automation_job_schedule" "peak" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azurerm_automation_runbook.carbon_optimization.name
  schedule_name           = azurerm_automation_schedule.peak.name

  parameters = {
    subscriptionid    = var.subscription_id
    resourcegroupname = var.resource_group_name
    keyvaultname      = var.key_vault_name
  }
}
