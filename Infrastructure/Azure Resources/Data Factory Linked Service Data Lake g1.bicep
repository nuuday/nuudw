// Resource specific params
param DataFactoryName string
param DataLakeLinkedServiceName string
param DataLakeUri string
param SubscriptionId string
param ResourceGroupName string

resource adflsdlg1 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${DataFactoryName}/${DataLakeLinkedServiceName}'
  properties: {
    annotations: []
    type: 'AzureDataLakeStore'
    typeProperties: {
      dataLakeStoreUri: DataLakeUri
      subscriptionId: SubscriptionId
      resourceGroupName: ResourceGroupName
    }
  }
}
