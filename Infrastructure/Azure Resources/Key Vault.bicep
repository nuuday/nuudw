// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string
param Environment string
param TenantId string
param AADAdminObjectID string
param DataFactoryPrincipalId string
param DevOpsServicePrincipalObjectID string
param AutomationPrincipalId string



resource kv 'Microsoft.KeyVault/vaults@2020-04-01-preview' = {
  name: Name
  location: Location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    accessPolicies: [
      {
        objectId: AADAdminObjectID
        tenantId: TenantId
        permissions: {
          secrets: [ 
            'get' 
            'list' 
            'set' 
	          'delete'
          ]
        }
      }
      {
        objectId: AutomationPrincipalId 
        tenantId: TenantId
        permissions: {
          secrets: [ 
            'get' 
            'list' 
            'set' 
	          'delete'
          ]
        }
      }      
      {
        objectId: DataFactoryPrincipalId
        tenantId: TenantId
        permissions: {
          secrets: [ 
            'get' 
            'list' 
            'set' 
          ]
        }
      }      
      {
        objectId: DevOpsServicePrincipalObjectID 
        tenantId: TenantId
        permissions: {
          secrets: [ 
            'get' 
            'list' 
            'set' 
          ]
        }
      }
    ]
    tenantId: TenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
  }
  tags: Tags
}


output KeyVaultName string = kv.name
output KeyVaultUri string = kv.properties.vaultUri
output KeyVaultId string = kv.id
