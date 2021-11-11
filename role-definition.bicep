var roleName = 'Azure Image Builder Contributor'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleName)
  properties: {
    roleName: roleName
    description: 'Manages images and image versions in gallery'
    assignableScopes: [
      resourceGroup().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'

          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
        notActions: [
        ]
      }
    ]
  }
}

output id string = last(split(roleDefinition.id, '/'))
