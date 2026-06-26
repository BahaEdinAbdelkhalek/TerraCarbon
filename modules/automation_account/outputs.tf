output "name" {
  description = "Automation Account name"
  value       = azurerm_automation_account.this.name
}

output "id" {
  description = "Full Azure resource ID of the Automation Account"
  value       = azurerm_automation_account.this.id
}

output "principal_id" {
  description = "Managed identity principal ID — used for role assignments"
  value       = azurerm_automation_account.this.identity[0].principal_id
}
