param location string
param appRegistrationId string
param apis array
param azureAdDomain string

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
      appSettings: [
        {
          name: 'AzureAd:Instance'
          value: 'https://login.microsoftonline.com/'
        }
        {
          name: 'AzureAd:Domain'
          value: azureAdDomain
        }
        {
          name: 'AzureAd:TenantId'
          value: tenant().tenantId
        }
        {
          name: 'AzureAd:ClientId'
          value: appRegistrationId
        }
      ]
    }
  }
}]
