// Resource specific params
param DataFactoryName string
param KeyVaultLinkedServiceName string = ''
param IntegrationRuntimeName string = ''
param SQLDBName string = ''

resource adflssqldb 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${DataFactoryName}/${SQLDBName}'
  properties: {
    annotations: []
    type: 'SqlServer'
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
    connectVia: {
	  referenceName: IntegrationRuntimeName 
          type: 'IntegrationRuntimeReference'
		}
	}
}
