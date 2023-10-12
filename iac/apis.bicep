param location string
param apis array = [
  'server-api'
  'basket-api'
]

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
