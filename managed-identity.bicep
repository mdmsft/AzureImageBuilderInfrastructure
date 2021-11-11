resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${resourceGroup().name}'
  location: resourceGroup().location
}

output id string = managedIdentity.id
output principalId string = managedIdentity.properties.principalId
