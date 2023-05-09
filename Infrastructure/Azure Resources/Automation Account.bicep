// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string


resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: Name
  location: Location 
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
  tags: Tags
}

output AutomationManagedIdentity object = aa.identity
