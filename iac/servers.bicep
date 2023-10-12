param location string
param apis array = [
  'server-api'
  'basket-api'
]

var prefix = 'evdb-demo-api2api'

resource asp 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: 'api2api'
}

resource serverApi 'Microsoft.Web/sites@2022-09-01' = [for api in apis: {
  name: '${prefix}-${api}'
  location: location
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}]


