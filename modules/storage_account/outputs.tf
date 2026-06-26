output "id" {
  description = "Full Azure resource ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_connection_string" {
  description = "Primary connection string for Logic Apps runtime"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}
