// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string
@allowed([
  'D1'
  'B1'
  'B2'
  'S0'
  'S1'
  'S2'
  'S4'
  'S8v2'
  'S9v2'
])
param Sku string
param FirewallAllowPBI bool = true
param FirewallEnable bool = true
param FirewallRules array = []
param Administrators object = {}



// Create AAS
resource aas 'Microsoft.AnalysisServices/servers@2017-08-01' = {
  location: Location
  name: Name
  sku: {
    name: Sku
  }
  tags: Tags
  properties: {
    ipV4FirewallSettings: !FirewallEnable ? {} : {
      enablePowerBIService: FirewallAllowPBI
      firewallRules: FirewallRules
    }
    asAdministrators: Administrators
  }
}


output AnalysisServicesName string = aas.name
output AnalysisServicesLocation string = aas.location
output AnalysisServicesFullName string = aas.properties.serverFullName
output AnalysisServicesId string = aas.id
