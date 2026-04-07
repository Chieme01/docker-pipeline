resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "github-actions-managed-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "mi_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Container Registry Repository Contributor"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

# resource "azurerm_federated_identity_credential" "github" {
#   name                = "github-actions-federation"
#   resource_group_name = "devops-pipelines-rg"
#   # This links the credential to your Managed Identity
#   parent_id           = azurerm_user_assigned_identity.example.id
  
#   # Standard OIDC audience for Azure
#   audience            = ["api://AzureADTokenExchange"]
  
#   # The GitHub OIDC issuer
#   issuer              = "https://token.actions.githubusercontent.com"
  
#   # The "Subject" depends on your repo and branch (see below)
#   subject             = "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:ref:refs/heads/main"
# }