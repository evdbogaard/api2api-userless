param location string
param appRegistrationId string
param appRegistrationObjectId string
param updateTag string = utcNow('u')

var prefix = 'evdb-demo-api2api'

param roles array = [
  'server-api'
  'order-api'
]

resource asp 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: 'api2api'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-client-api'
  location: location
}

resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'api2api-script'
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
        value: appRegistrationObjectId
      }
      {
        name: 'roles'
        value: join(roles, ',')
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
      netFrameworkVersion: 'v8.0'
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ManagedIdentity'
          value: managedIdentity.properties.clientId
        }
        {
          name: 'AppRegistrationId'
          value: appRegistrationId
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
