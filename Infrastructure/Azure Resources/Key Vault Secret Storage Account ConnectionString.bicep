param KeyVaultName string
param SecretName string
@secure()
param SecretContentType string
param StorageAccountName string
param StorageAccountId string
param StorageAccountAPIVersion string

var StorageAccountKey = listkeys(StorageAccountId, StorageAccountAPIVersion).keys[0].value
var StorageAccountSuffix = environment().suffixes.storage

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${KeyVaultName}/${SecretName}'
  properties:{
    contentType: SecretContentType
    value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccountName};AccountKey=${StorageAccountKey};EndpointSuffix=${StorageAccountSuffix}'
  }
}
