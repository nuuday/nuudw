// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string

// Params about Log Analytics, can be left out if you don't want it
@secure()
param LogAnalyticsWorkspaceId string = ''
param DeployLogAnalytics bool = false

resource adls 'Microsoft.DataLakeStore/accounts@2016-11-01' = {
  location: Location
  name: Name
  tags: Tags
  properties: {
    firewallState: 'Disabled'
    firewallAllowAzureIps: 'Disabled'
    trustedIdProviderState: 'Disabled'
    encryptionState: 'Enabled'
    encryptionConfig: {
      type: 'ServiceManaged'
    }
    newTier: 'Consumption'
  }
}

resource adlsLA 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if(DeployLogAnalytics) {
  name: 'diag-${adls.name}'
  scope: adls
  properties: {
    workspaceId: LogAnalyticsWorkspaceId
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
      {
        category: 'Requests'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output DataLakeId string = adls.id
output DataLakeUri string = 'https://${adls.properties.endpoint}/webhdfs/v1'
