param location string
param apis array = [
  'server-api'
  'basket-api'
]
param updateTag string = utcNow('u')

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'api2api'
  location: location
  sku: {
    name: 'F1'
  }
}

module client 'client.bicep' = {
  name: 'api2api-deploy-client'
  params: {
    location: location
  }
}

module servers 'servers.bicep' = {
  name: 'api2api-deploy-servers'
  params: {
    location: location
    apis: apis
  }
}

// Something to do the app registration
resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'api2api-script'
}

resource appRegistration 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'evdb-demo-api2api-app-registation-ds'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    retentionInterval: 'P1D'
    forceUpdateTag: updateTag
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('appRegistration.ps1')
    environmentVariables: [
      {
        name: 'tenantId'
        value: tenant().tenantId
      }
      {
        name: 'servers'
        value: join(apis, ',')
      }
    ]
  }
}
