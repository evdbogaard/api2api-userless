targetScope = 'subscription'

param azureAdDomain string
param location string = 'westeurope'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'api2api'
  location: location
}

module apis './apis.bicep' = {
  name: 'apis'
  scope: rg
  params: {
    location: location
    azureAdDomain: azureAdDomain
  }
}
