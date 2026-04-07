resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "github-actions-managed-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "mi_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

