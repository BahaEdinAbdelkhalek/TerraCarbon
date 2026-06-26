output "name" {
  description = "Logic App workflow name"
  value       = azurerm_logic_app_workflow.this.name
}

output "id" {
  description = "Full Azure resource ID of the Logic App"
  value       = azurerm_logic_app_workflow.this.id
}

output "principal_id" {
  description = "Managed identity principal ID of the Logic App"
  value       = azurerm_logic_app_workflow.this.identity[0].principal_id
}
