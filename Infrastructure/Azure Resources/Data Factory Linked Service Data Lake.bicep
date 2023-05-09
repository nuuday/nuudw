// Resource specific params
param DataFactoryName string
param KeyVaultLinkedServiceName string = ''
param DataLakeLinkedServiceName string

resource adflsdl 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${DataFactoryName}/${DataLakeLinkedServiceName}'
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${DataLakeLinkedServiceName}Url'
      }
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${DataLakeLinkedServiceName}Key'
      }
    }
  }
}
