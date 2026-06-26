resource "azurerm_key_vault" "this" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "admin_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.admin_object_id
}

resource "azurerm_key_vault_secret" "carbon_threshold" {
  name         = "carbon-threshold-kg"
  value        = var.carbon_threshold_kg
  key_vault_id = azurerm_key_vault.this.id
  content_type = "text/plain"
  depends_on   = [azurerm_role_assignment.admin_secrets_officer]
}

resource "azurerm_key_vault_secret" "cost_threshold" {
  name         = "cost-threshold-usd"
  value        = var.cost_threshold_usd
  key_vault_id = azurerm_key_vault.this.id
  content_type = "text/plain"
  depends_on   = [azurerm_role_assignment.admin_secrets_officer]
}

resource "azurerm_key_vault_secret" "min_carbon_reduction" {
  name         = "min-carbon-reduction-percent"
  value        = var.min_carbon_reduction_percent
  key_vault_id = azurerm_key_vault.this.id
  content_type = "text/plain"
  depends_on   = [azurerm_role_assignment.admin_secrets_officer]
}

resource "azurerm_key_vault_secret" "cpu_threshold" {
  name         = "cpu-utilization-threshold"
  value        = var.cpu_utilization_threshold
  key_vault_id = azurerm_key_vault.this.id
  content_type = "text/plain"
  depends_on   = [azurerm_role_assignment.admin_secrets_officer]
}
