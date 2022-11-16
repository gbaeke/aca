param parLocation string = resourceGroup().location



resource env 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: 'env-aca'
}

resource sb 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: 'academogeba'
}

var serviceBusEndpoint = '${sb.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, sb.apiVersion).primaryConnectionString

resource pubsub 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: '${env.name}/pubsub'
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    secrets: [
      {
        name: 'connstr'
        value: serviceBusConnectionString
      }
    ]
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'connstr'
      }
    ]
    scopes: [
      'pubsub'
    ]
  }
  
}

resource app 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'pubsub'
  location: parLocation
  tags: {
    env: 'dev'
  }
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      secrets: [
        {
          name: 'sbauth'
          value: serviceBusConnectionString
        }
      ]
      dapr: {
        appId: 'pubsub'
        appPort: 8080
        enabled: true
      }
    }
    managedEnvironmentId: env.id
    template: {
      containers: [
        {
          image: 'ghcr.io/gbaeke/super:1.0.7'
          name: 'pubsub'

        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 4
        rules: [
          {
            name: 'servicebus'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: 'mytopic'
                messageCount: '2'
                subscriptionName: 'pubsub'              
              }
              auth: [
                {
                  triggerParameter: 'connection'
                  secretRef: 'sbauth'
                }
              ]
            }
          }
        ]
      }
    }  

}
}
