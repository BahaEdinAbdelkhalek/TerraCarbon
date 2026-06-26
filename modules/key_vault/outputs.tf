output "id" {
  description = "Full Azure resource ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "uri" {
  description = "Key Vault URI for programmatic access"
  value       = azurerm_key_vault.this.vault_uri
}
