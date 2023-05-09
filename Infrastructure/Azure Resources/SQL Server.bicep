// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string
@secure()
param AdminLogin string 
@secure()
param AdminPassword string 
param SetAADAdmin bool = true
param AADAdminTenantId string = ''
param AADAdminUPN string = ''
param AADAdminOId string = ''
param AllowAzureIps bool = true
param SqlServerEnableATP bool = false


resource SqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: Name
  location: Location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: AdminLogin
    administratorLoginPassword: AdminPassword
    version: '12.0'
  }
  tags: Tags
}

resource FireWallAllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = if (AllowAzureIps) {
  name: '${SqlServer.name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource FirewallAllowKapacityCPH 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  name: '${SqlServer.name}/KapacityCPH'
  properties: {
    endIpAddress: '176.22.116.13'
    startIpAddress: '176.22.116.13'
  }
}

resource FirewallAllowKapacityKOL 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  name: '${SqlServer.name}/KapacityKOL'
  properties: {
    endIpAddress: '185.20.241.226'
    startIpAddress: '185.20.241.226'
  }
}

resource FirewallAllowKapacityAAR 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  name: '${SqlServer.name}/KapacityAAR'
  properties: {
    endIpAddress: '62.242.35.179'
    startIpAddress: '62.242.35.179'
  }
}

resource FirewallAllowCustomerIP 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  name: '${SqlServer.name}/CustomerIP'
  properties: {
    endIpAddress: '94.101.208.244'
    startIpAddress: '94.101.208.244'
  }
}

resource SqlServerAADAdmin 'Microsoft.Sql/servers/administrators@2019-06-01-preview' = if (SetAADAdmin) {
  name: '${SqlServer.name}/activeDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: AADAdminUPN
    sid: AADAdminOId
    tenantId: AADAdminTenantId
  }
}

output SqlServerId string = SqlServer.id
output SqlServerName string = SqlServer.name
output SqlServerFQDN string = SqlServer.properties.fullyQualifiedDomainName
