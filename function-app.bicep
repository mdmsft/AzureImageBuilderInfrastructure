@secure()
param personalAccessToken string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'st${resourceGroup().name}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource serverFarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${resourceGroup().name}'
  location: resourceGroup().location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-${resourceGroup().name}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${resourceGroup().name}'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource azureFunction 'Microsoft.Web/sites@2021-02-01' = {
  name: 'func-${resourceGroup().name}'
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      scmType: 'GitHub'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'func-${resourceGroup().name}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsComponents.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsComponents.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'ADO_PAT'
          value: personalAccessToken
        }
        {
          name: 'ADO_ORG_PRJ'
          value: 'loscontosos/AiB'
        }
        {
          name: 'ADO_PIPELINE'
          value: '2'
        }
      ]
    }
  }

  resource github 'sourcecontrols' = {
    name: 'web'
    properties: {
      branch: 'master'
      repoUrl: 'https://github.com/mdmsft/AzureImageBuilderFunctionApp'
    }
  }
}

// output id string = azureFunction::function.id
output id string = '${azureFunction.id}/functions/AzureImageBuilder'
