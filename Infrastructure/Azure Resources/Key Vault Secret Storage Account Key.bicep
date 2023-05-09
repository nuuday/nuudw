param KeyVaultName string
param SecretName string
param StorageAccountId string
param StorageAccountAPIVersion string
@secure()
param SecretContentType string

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${KeyVaultName}/${SecretName}'
  properties:{
    contentType: SecretContentType
    value: listkeys(StorageAccountId, StorageAccountAPIVersion).keys[0].value
  }
}
