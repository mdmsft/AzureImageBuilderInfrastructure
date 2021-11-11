@secure()
param personalAccessToken string

module role 'role-definition.bicep' = {
  name: '${deployment().name}-role'
}

module identity 'managed-identity.bicep' = {
  name: '${deployment().name}-identity'
}

module template 'image-template.bicep' = {
  name: '${deployment().name}-template'
  params: {
    managedIdentity: {
      id: identity.outputs.id
      principalId: identity.outputs.principalId
    }
    roleDefinitionId: role.outputs.id 
  }
}

module function 'function-app.bicep' = {
  name: '${deployment().name}-function'
  params: {
    personalAccessToken: personalAccessToken
  }
}

module grid 'event-grid.bicep' = {
  name: '${deployment().name}-grid'
  params: {
    azureFunctionId: function.outputs.id
  }
}
