param managedIdentity object
param roleDefinitionId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(managedIdentity.principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    principalId: managedIdentity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

var name = 'win-srv-2k19'

resource gallery 'Microsoft.Compute/galleries@2021-07-01' = {
  name: resourceGroup().name
  location: resourceGroup().location

  resource image 'images' = {
    name: name
    location: resourceGroup().location
    properties: {
      osType: 'Windows'
      identifier: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2019-datacenter'
      }
      osState: 'Generalized'
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: name
  location: resourceGroup().location
  dependsOn: [
    roleAssignment
    gallery::image
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 180
    vmProfile: {
      vmSize:  'Standard_DS2_v2'
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        runElevated: true
        runAsSystem: true
        name: 'AzCopy'
        inline: [
          'New-Item -Type Directory -Path \'c:\\\' -Name \'temp\''
          'Invoke-Webrequest -uri \'https://aka.ms/downloadazcopy-v10-windows\' -OutFile \'c:\\temp\\azcopy.zip\''
          'Expand-Archive \'c:\\temp\\azcopy.zip\' \'c:\\temp\''
          'Copy-Item \'c:\\temp\\azcopy_windows_amd64_*\\azcopy.exe\\\' -Destination \'c:\\temp\''
          'Remove-Item \'c:\\temp\\azcopy.zip\''
          'Remove-Item \'c:\\temp\\azcopy_windows_amd64_*\' -Recurse'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: gallery::image.id
        runOutputName: name
        replicationRegions: [
          resourceGroup().location
        ]
      }
    ]
  }
}

output imageId string = gallery::image.id
