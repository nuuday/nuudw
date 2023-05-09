// Resource specific params
param DataFactoryName string
param KeyVaultLinkedServiceName string = ''
param SQLDBName string = ''

resource adflssqldb 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${DataFactoryName}/${SQLDBName}'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: KeyVaultLinkedServiceName
          type: 'LinkedServiceReference'
        }
        secretName: 'ConnectionString-${SQLDBName}'
      }
    }
  }
}
