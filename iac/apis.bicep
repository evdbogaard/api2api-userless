param location string

// App service plan
resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'api2api'
  location: location
  sku: {
    name: 'F1'
  }
}

// Api1
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'api2api-api1'
  location: location
}

resource api1 'Microsoft.Web/sites@2022-09-01' = {
  name: 'api2api-api1'
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
