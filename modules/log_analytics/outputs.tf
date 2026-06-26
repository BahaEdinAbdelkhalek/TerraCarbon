output "id" {
  description = "Full Azure resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics workspace GUID (used by queries)"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key (sensitive)"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
