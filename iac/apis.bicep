param location string
param appRegistrationId string = '22df344e-6808-40ef-b60d-720ff244207f'
param updateTag string = utcNow('u')

var prefix = 'evdb-demo-api2api'

resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'api2api-script'
}

// App service plan
resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'api2api'
  location: location
  sku: {
    name: 'F1'
  }
}

// Api client
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-client-api'
  location: location
}

resource appRoleAssignment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${prefix}-client-api-ds'
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
    scriptContent: loadTextContent('appRoleAssignment.ps1')
    environmentVariables: [
      {
        name: 'tenantId'
        value: tenant().tenantId
      }
      {
        name: 'principalId'
        value: managedIdentity.properties.principalId
      }
      {
        name: 'appRegistrationId'
        value: appRegistrationId
      }
    ]
  }
}

resource clientApi 'Microsoft.Web/sites@2022-09-01' = {
  name: '${prefix}-client-api'
  location: location
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ManagedIdentity'
          value: managedIdentity.properties.clientId
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
}

// Api2
