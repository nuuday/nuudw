// Resource specific params
param DataFactoryName string
param KeyVaultLinkedServiceName string = ''
param FunctionName string = ''

resource adflssqldb 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${DataFactoryName}/${FunctionName}'
  properties: {
    annotations: []
    type: 'AzureFunction'
    typeProperties: {
      functionAppUrl: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${FunctionName}Url'
      }
      functionKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${FunctionName}Key'
      }
      authentication: 'Anonymous'
    }
  }
}
