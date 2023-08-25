targetScope = 'subscription'

@description('Location for all resources.')
param rgLocation string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-myjavaapp'
  location: rgLocation
}

module appi './appi.bicep' = {
  name: 'appiDeployment'
  scope: rg
  params: {
    location: rg.location
  }
}
