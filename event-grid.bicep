param azureFunctionId string

resource systemTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: resourceGroup().name
  location: 'global'
  properties: {
    topicType: 'Microsoft.Resources.ResourceGroups'
    source: resourceGroup().id
  }

  resource subscription 'eventSubscriptions' = {
    name: 'functionapp'
    properties: {
      eventDeliverySchema: 'EventGridSchema'
      filter: {
        includedEventTypes: [
          'Microsoft.Resources.ResourceWriteSuccess'
        ]
      }
      destination: {
        endpointType: 'AzureFunction'
        properties: {
          resourceId: azureFunctionId
          maxEventsPerBatch: 1
        }
      }
      retryPolicy: {
        maxDeliveryAttempts: 30
        eventTimeToLiveInMinutes: 30
      }
    }
  }
}
