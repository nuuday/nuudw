param ContainerName string = ''
param StorageAccountName string = ''

resource blobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${StorageAccountName}/default/${ContainerName}'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    metadata: {}
    publicAccess: 'None'
  }
}
