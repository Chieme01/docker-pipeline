data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                            = "NYONgithubKeyVault"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false

  sku_name = "standard"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "client_id_secret" {
  name         = "client-id-secret"
  value        = azurerm_user_assigned_identity.managed_identity.client_id
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "tenant_id_secret" {
  name         = "tenant-id-secret"
  value        = azurerm_user_assigned_identity.managed_identity.tenant_id
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "subscription_id_secret" {
  name         = "subscription-id-secret"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.key_vault.id
}