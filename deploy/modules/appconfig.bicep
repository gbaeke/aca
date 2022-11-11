@description('App Configuration Name')
param parAppConfigName string

@description('Location to deploy resources')
param parLocation string

@description('Create demo config value')
param parCreateDemoConfig bool

@description('Enable private endpoint for the key vault')
param parEnablePrivateLink bool

@description('ID of the private DNS zone for App Config')
param parPrivateDNSZoneId string

@description('Subnet ID for private endpoint interface')
param parSubnetId string

// deploy Azure App Configuration
resource configStore 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: parAppConfigName
  location: parLocation
  sku: {
    name: 'standard'
  }
}

// create Private Endpoint if private link is enabled in provided subnet id
resource acPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = if (parEnablePrivateLink) {
  name: 'pe${parAppConfigName}'
  location: parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe${parAppConfigName}'
        properties: {
          groupIds: [
            'configurationStores'
          ]
          privateLinkServiceId: configStore.id
        }
      }
    ]
    subnet: {
      id: parSubnetId
    }
  }
}

// register A record in private DNS zone if private link is enabled
resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = if (parEnablePrivateLink) {
  name: '${acPrivateEndpoint.name}/ac-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azconfig.io'
        properties:{
          privateDnsZoneId: parPrivateDNSZoneId
        }
      }
    ]
  }
}

// add a sample key value pair
resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = if (parCreateDemoConfig) {
  parent: configStore
  name: 'myapp:appkey$prd'
  properties: {
    value: 'othervalue'
  }
}
