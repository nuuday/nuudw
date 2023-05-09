// Resource specific params
param DataFactoryName string
param KeyVaultUri string = ''
param KeyVaultLinkedServiceName string = ''

resource adflskv 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${DataFactoryName}/${KeyVaultLinkedServiceName}'
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: KeyVaultUri
    }
  }
}