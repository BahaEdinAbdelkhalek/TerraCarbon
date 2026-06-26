resource "azurerm_logic_app_workflow" "this" {
  name                = var.logic_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }

  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"
  workflow_parameters = {}

  parameters = {
    "$definition" = jsonencode({
      "$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
      contentVersion = "1.0.0.0"
      parameters     = {}

      triggers = {
        Recurrence = {
          recurrence = {
            frequency = "Day"
            interval  = 1
            timeZone  = "UTC"
            schedule = {
              hours   = ["2"]
              minutes = [0]
            }
          }
          type = "Recurrence"
        }
      }

      actions = {
        Get_Carbon_Intensity = {
          type = "Http"
          inputs = {
            method = "GET"
            uri    = "https://api.carbonintensity.org.uk/intensity"
          }
        }

        Parse_Carbon_Intensity = {
          type = "ParseJson"
          inputs = {
            content = "@body('Get_Carbon_Intensity')"
            schema = {
              type = "object"
              properties = {
                data = {
                  type = "array"
                  items = {
                    type = "object"
                    properties = {
                      intensity = {
                        type = "object"
                        properties = {
                          actual   = { type = "integer" }
                          forecast = { type = "integer" }
                          index    = { type = "string" }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          runAfter = {
            Get_Carbon_Intensity = ["Succeeded"]
          }
        }

        Check_Carbon_Threshold = {
          type = "If"
          expression = {
            and = [{
              less = [
                "@body('Parse_Carbon_Intensity')?['data']?[0]?['intensity']?['actual']",
                200
              ]
            }]
          }

          actions = {
            Trigger_Runbook = {
              type = "Http"
              inputs = {
                method = "POST"
                uri    = "https://management.azure.com/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Automation/automationAccounts/${var.automation_account_name}/jobs?api-version=2023-11-01"
                headers = {
                  "Content-Type" = "application/json"
                }
                body = {
                  properties = {
                    runbook = {
                      name = "CarbonOptimizationRunbook"
                    }
                    parameters = {
                      subscriptionid    = var.subscription_id
                      resourcegroupname = var.resource_group_name
                      keyvaultname      = var.key_vault_name
                    }
                  }
                }
                authentication = {
                  type = "ManagedServiceIdentity"
                }
              }
            }
          }

          else = {
            actions = {}
          }

          runAfter = {
            Parse_Carbon_Intensity = ["Succeeded"]
          }
        }
      }
    })
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "automation_operator" {
  scope                = var.automation_account_id
  role_definition_name = "Automation Operator"
  principal_id         = azurerm_logic_app_workflow.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "log_analytics_contributor" {
  scope                = var.log_analytics_id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_logic_app_workflow.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_logic_app_workflow.this.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "logic_app" {
  name                       = "diag-${var.logic_app_name}"
  target_resource_id         = azurerm_logic_app_workflow.this.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "WorkflowRuntime"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
