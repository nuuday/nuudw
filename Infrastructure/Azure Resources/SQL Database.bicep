// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param SqlServerName string
param Name string
param SqlDatabaseLicenseType string = 'LicenseIncluded'
param SqlDatabaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'
@allowed([
  {
    Name: 'Basic'
    Tier: 'Basic'
    Capacity: 5
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 10
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 20
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 50
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 100
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 200
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 400
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 800
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 1600
  }
  {
    Name: 'Standard'
    Tier: 'Standard'
    Capacity: 3000
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 2
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 4
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 6
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 8
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 10
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 12
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 14
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 16
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 18
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 20
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 24
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 32
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 40
  }
  {
    Name: 'HS_Gen5'
    Tier: 'Hyperscale'
    Capacity: 80
  }
  {
    Name: 'GP_S_Gen5'
    Tier: 'GeneralPurpose'
    Capacity: 2
  }
  {
    Name: 'GP_S_Gen5'
    Tier: 'GeneralPurpose'
    Capacity: 4
  }
])
param SqlDatabaseTier object
param SqlDatabaseMaxSize int



resource SqlDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${SqlServerName}/${Name}'
  sku: {
    name: SqlDatabaseTier.Name
    tier: SqlDatabaseTier.Tier
    capacity: SqlDatabaseTier.Capacity
  }
  location: Location
  properties: {
    collation: SqlDatabaseCollation
    licenseType: SqlDatabaseLicenseType
    highAvailabilityReplicaCount: 0
    maxSizeBytes: SqlDatabaseMaxSize == 0 ? null : 1024 * 1024 * 1024 * SqlDatabaseMaxSize
  }
  tags: Tags
}


output SqlDatabaseId string = SqlDatabase.id
output SqlDatabaseName string = SqlDatabase.name
output SqlDatabaseDatabaseId string = SqlDatabase.properties.databaseId
