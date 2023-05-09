// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string
@allowed([
  'Cool'
  'Hot'
])
param StorageAccountAccessTier string = 'Cool'
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_LRS'
  'Standard_GZRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
])
@description('Which replication type should storage account use?')
param StorageAccountSKU string = 'Standard_LRS'
param IsDataLake bool 


resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: Name
  location: Location
  properties: {
    accessTier: StorageAccountAccessTier
    supportsHttpsTrafficOnly: true
    isHnsEnabled: IsDataLake
  }
  sku: {
    name: StorageAccountSKU
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  tags: Tags
}
resource StorageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2021-01-01' = {
  name: 'default'
  parent: StorageAccount
}

output StorageAccountManagedIdentity object = StorageAccount.identity
output StorageAccountManagedIdentityPrincipalId string = StorageAccount.identity.principalId
output StorageAccountId string = StorageAccount.id
output StorageAccountPrimaryEndpoints object = StorageAccount.properties.primaryEndpoints
output StorageAccountPrimaryEndpointsBlob string = StorageAccount.properties.primaryEndpoints.blob
output StorageAccountAPIVersion string = StorageAccount.apiVersion
//output StorageAccountKey string = listKeys(StorageAccount.id, StorageAccount.apiVersion).keys[0].value
