@description('Key Vault prefix')
param parKvPrefix string = 'kv-'

@description('Create demo config value')
param parCreateDemoConfig bool = true

@description('ObjectId of user or group with reader  access to key vault secrets')
param parKVReaderObjectId string

@description('ObjectId of user or group with admin access to key vault')
param parKVAdminObjectId string


@description('Location to deploy resources')
param parLocation string = 'westeurope'

@description('Key vault app and environment name')
param parKeyVaults array = [
  'aca-geba'
]

@description('App Configuration Name')
param appConfigName string = 'ac-appconfig-${uniqueString(resourceGroup().id)}'

@description('Enable private endpoint for the key vault')
param parEnablePrivateLink bool = false

@description('Subnet ID for private endpoint interface')
param parSubnetId string = ''

@description('ID of the private DNS zone for Key Vault')
param parKVPrivateDNSZoneId string = ''

@description('ID of the private DNS zone for App Config')
param parACPrivateDNSZoneId string = ''

@description('Principal type to grant access to key vault')
@allowed([
  'User'
  'Group'
])
param parPrincipalType string = 'Group'




// deploy multiple key vaults
module kv 'modules/kv.bicep' = [for parKeyVault in parKeyVaults: {
  name: '${parKvPrefix}${parKeyVault}'
  params: {
    parKVReaderObjectId: parKVReaderObjectId
    parKVAdminObjectId: parKVAdminObjectId
    parLocation: parLocation
    parKVName: parKeyVault
    parKvPrefix: parKvPrefix
    parEnablePrivateLink: parEnablePrivateLink
    parSubnetId: parSubnetId
    parPrivateDNSZoneId: parKVPrivateDNSZoneId
    parPrincipalType: parPrincipalType
  }
}]

// deploy app config
module ac 'modules/appconfig.bicep' = {
  name: 'ac-${appConfigName}'
  params: {
    parLocation: parLocation
    parAppConfigName: appConfigName
    parCreateDemoConfig: parCreateDemoConfig
    parEnablePrivateLink: parEnablePrivateLink
    parPrivateDNSZoneId: parACPrivateDNSZoneId
    parSubnetId: parSubnetId
  }
}




