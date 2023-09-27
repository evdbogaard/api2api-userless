# api2api-userless

### Notes to self
- Create app registration
- App roles -> Create app role
- API permissions -> Add a permissions && Give admin consent
- Expose an API -> Add a scope
- Expose an API -> Add a client application (Azure CLI) (For local connection)

Powershell part (for now, to connect identity to the app registration. This creates an enterprise application for that identity/app)
- Install-Module Microsoft.Graph -Scope CurrentUser
- Msgraph-login -tenant tenantId
- New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId managedIdentityOfApp -PrincipalId managedIdentityOfApp -ResourceId EnterpriseApplicationOfCreatedAppRegistrationObjectId -AppRoleId createdAppRoleId