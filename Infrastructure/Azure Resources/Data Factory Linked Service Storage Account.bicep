// Resource specific params
param DataFactoryName string
param KeyVaultLinkedServiceName string = ''
param StorageAccountLinkedServiceName string

resource adflssa 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${DataFactoryName}/${StorageAccountLinkedServiceName}'
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${StorageAccountLinkedServiceName}'
      }
    }
  }
}
