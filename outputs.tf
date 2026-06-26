output "resource_group_name" {
  description = "the deployed resource group name "
  value       = module.resource_group.name
}


output "resource_group_location" {
  description = "the deployed resource group location "
  value       = module.resource_group.location
}


output "resource_group_id" {
  description = "the deployed resource group id "
  value       = module.resource_group.id
}


output "log_analytics_workspace_id" {
  description = "Log Analytics workspace GUID"
  value       = module.log_analytics.workspace_id
}

output "log_analytics_resource_id" {
  description = "Full Azure resource ID of the Log Analytics workspace"
  value       = module.log_analytics.id
}


output "key_vault_name" {
  description = "Key Vault name — needed by the runbook"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.uri
}




output "automation_account_name" {
  description = "Automation Account name"
  value       = module.automation_account.name
}

output "automation_principal_id" {
  description = "Managed identity ID of the Automation Account"
  value       = module.automation_account.principal_id
}


output "storage_account_name" {
  description = "Storage account name used by Logic Apps"
  value       = module.storage_account.name
}


output "logic_app_name" {
  description = "Logic App workflow name"
  value       = module.logic_app.name
}

output "logic_app_principal_id" {
  description = "Managed identity of the Logic App"
  value       = module.logic_app.principal_id
}
