param parKvPrefix string

param parKVReaderObjectId string
param parKVAdminObjectId string

param parLocation string

param parKVName string

param parEnablePrivateLink bool

param parSubnetId string

param parPrivateDNSZoneId string

param parPrincipalType string

// create Key Vault with Azure Rbac authorization
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${parKvPrefix}${parKVName}'
  location: parLocation
  properties: {
    sku: {
      family: 'A'
      name: 'standard'

    }
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
  }
}


// create Private Endpoint if private link is enabled in provided subnet id
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = if (parEnablePrivateLink) {
  name: 'pe${parKvPrefix}${parKVName}'
  location: parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe${parKvPrefix}${parKVName}'
        properties: {
          groupIds: [
            'vault'
          ]
          privateLinkServiceId: kv.id
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
  name: '${keyVaultPrivateEndpoint.name}/vault-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.vaultcore.azure.net'
        properties:{
          privateDnsZoneId: parPrivateDNSZoneId
        }
      }
    ]
  }
}


// grant key vault secrets user role to reader group id
var kvReaderRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
resource kvReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, kv.id, kvReaderRoleId)
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvReaderRoleId)
    principalId: parKVReaderObjectId
    principalType: parPrincipalType
  }
}

// grant key vault admin role to a admin group id
var kvAdminRoleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
resource kvAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, kv.id, kvAdminRoleId)
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvAdminRoleId)
    principalId: parKVAdminObjectId
    principalType: parPrincipalType
  }
}


