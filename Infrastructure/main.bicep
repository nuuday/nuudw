@allowed([
  'Development'
  'Test/QA'
  'PreProduction'
  'Production'
])
@description('Please provide the environment being deployed (typically thru parameter files)')
param Environment string
param ProjectName string
var EnvironmentVariable = Environment == 'Development' ? 'dev': Environment == 'Test/QA' ? 'test' : 'prod'

var SubscriptionId = subscription().subscriptionId
var TenantId = subscription().tenantId
var UniqueName = uniqueString(resourceGroup().name)


// General configuration
  // - Azure region for resources

  // - Enherit tags from resource group
  param EnheritTagsFromResourceGroup bool = true
  var Tags = !EnheritTagsFromResourceGroup ? {} : contains(resourceGroup(), 'tags') ? resourceGroup().tags : {}

  // - EnvironmentSpecific
  param AADAdminObjectID string
  param AADAdminUPN string

  var Location = resourceGroup().location  
  var ResourceGroupName = resourceGroup().name
// Resources
 
  // - Automation Account
  param CreateAutomationAccount bool = false
  param AutomationAccountName string

  module aa 'Azure Resources/Automation Account.bicep' = if (CreateAutomationAccount) {
    name: 'AutomationAccountDeploy-${UniqueName}'
    params: {
      Location: Location
      Name: AutomationAccountName
      Tags: Tags
    }
  }

    
  // - Analysis Services
  param DeployAnalysisServices bool = true
  param AnalysisServicesInstances array
  var AASAdmins = [
    'obj:${AADAdminObjectID}@${TenantId}'
    'app:${ServicePrincipalId}@${TenantId}'
  ]


  module aas 'Azure Resources/Analysis Services.bicep' = [for instance in DeployAnalysisServices ? AnalysisServicesInstances : range(0, 0) : {
    name: 'AnalysisServicesDeploy-${instance.InstanceName}-${UniqueName}'
    params: {
      Location: Location
      Tags: Tags
      Name: instance.InstanceName
      Sku: instance.InstanceSKU
      FirewallEnable: false
      Administrators: {
        members: AASAdmins
      }
    }
  }]

  // - Data Factory
    param DataFactoryName string = ''
    param DataFactoryGitAccountName string = ''
    param DataFactoryGitProjectName string = ''
    param DataFactoryGitRepositoryName string = ''
    param DataFactoryGitCollaborationBranch string = ''
    param DataFactoryGitRootFolder string = '' 
    var DataFactoryDeployKeyVaultLinkedService = true
    var KeyVaultLinkedServiceName = 'KeyVault'
    module adf 'Azure Resources/Data Factory.bicep' = {
      name: 'DataFactoryDeploy-${UniqueName}'
      params: {
        Location: Location
        Tags: Tags
        Name: DataFactoryName
        GlobalParams: {        
          KeyVaultName: {
            type: 'String'
            value: KeyVaultName
          }
        }
        AddGitRepo: Environment == 'Development'
        GitAccountName: DataFactoryGitAccountName
        GitProjectName: DataFactoryGitProjectName
        GitRepositoryName: DataFactoryGitRepositoryName
        GitCollaborationBranch: DataFactoryGitCollaborationBranch
        GitRootFolder: DataFactoryGitRootFolder
      }
    }
    module adflskv 'Azure Resources/Data Factory Linked Service Key Vault.bicep' = if (DataFactoryDeployKeyVaultLinkedService) {
      name: 'DataFactoryLinkedServiceKeyVaultDeploy-${UniqueName}'
      params: {
        DataFactoryName: adf.outputs.DataFactoryName
        KeyVaultLinkedServiceName: KeyVaultLinkedServiceName
        KeyVaultUri: kv.outputs.KeyVaultUri
      }
    }

    module adflsdw 'Azure Resources/Data Factory Linked Service Azure SQL DB.bicep' = if (DataFactoryDeployKeyVaultLinkedService) {
      name: 'DataFactoryLinkedServiceDWDeploy-${UniqueName}'
      dependsOn:[
        sqlsvr
        sqldb
      ]
      params: {
        DataFactoryName: adf.outputs.DataFactoryName
        KeyVaultLinkedServiceName: KeyVaultLinkedServiceName
        SQLDBName : SqlDatabases.DatabaseName
      }
    }


  // - SQL Server
  param SqlServerName string
  @secure()
  param SqlServerAdminUserName string 
  @secure()    
  param SqlServerAdminPassword string
 
  module sqlsvr 'Azure Resources/SQL Server.bicep' = {
    name: 'SqlServerDeploy-${UniqueName}'
    params: {
      Location: Location
      Tags: Tags
      Name: SqlServerName
      AdminLogin: SqlServerAdminUserName
      AdminPassword: SqlServerAdminPassword
      SetAADAdmin: true
      AADAdminOId: AADAdminObjectID
      AADAdminUPN: AADAdminUPN
      AADAdminTenantId: TenantId
    }
  }

// - SQL DB
  param DeploySqlDatabases bool = true
  param SqlDatabases object
  module sqldb 'Azure Resources/SQL Database.bicep' =  if(DeploySqlDatabases) {
    name: 'SqlDatabaseDeploy-${SqlDatabases.DatabaseName}-${UniqueName}'
    params: {
      Location: Location
      Tags: Tags
      Name: SqlDatabases.DatabaseName
      SqlDatabaseTier: SqlDatabases.DatabaseTier
      SqlDatabaseMaxSize: SqlDatabases.DatabaseMaxSize
      SqlDatabaseCollation: SqlDatabases.SqlDatabaseCollation
      SqlServerName: sqlsvr.outputs.SqlServerName
    }
  }

  // - Key Vault
  param KeyVaultName string
  param AzureDevOpsServicePrincipalObjectID string
  module kv 'Azure Resources/Key Vault.bicep' = {
    name: 'KeyVaultDeploy-${UniqueName}'
    params: {
      Location: Location
      Tags: Tags
      Name: KeyVaultName
      Environment: Environment
      TenantId: TenantId
      AADAdminObjectID: AADAdminObjectID
      DataFactoryPrincipalId: adf.outputs.DataFactoryManagedIdentity.principalId
      DevOpsServicePrincipalObjectID  : AzureDevOpsServicePrincipalObjectID
      AutomationPrincipalId :  aa.outputs.AutomationManagedIdentity.principalId
    }
  }

  module kvSecretSqlDb 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-${SqlDatabases.DatabaseName}-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: 'Server=tcp:${sqlsvr.outputs.SqlServerName}${environment().suffixes.sqlServerHostname},1433;Database=${SqlDatabases.DatabaseName};'
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ConnectionString-${SqlDatabases.DatabaseName}'
      SecretContentType: 'ConnectionString'
    }
  }

  module kvSecretssmsservername 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-SqlServerName-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: '${sqlsvr.outputs.SqlServerName}${environment().suffixes.sqlServerHostname}'
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'SSMSServerName'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretssmsserver 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-SqlServer-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: sqlsvr.outputs.SqlServerName
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'SSMSServer'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretssmsdatabasename 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-SSMSDatabaseName-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: SqlDatabases.DatabaseName
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'SSMSDatabaseName'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretadfname 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-ADFName-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: DataFactoryName
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ADFDataFactoryName'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretadfrgname 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-RGName-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: ResourceGroupName
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ADFResourceGroupName'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretsubscriptionid 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-SiD-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: SubscriptionId
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ADFSubscriptionID'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecrettenantid 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-TiD-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: TenantId
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ADFTenantID'
      SecretContentType: 'Deployment'
    }
  }


  param ServicePrincipalId string = ''
  module kvSecretClientId 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-ADFClientID-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: ServicePrincipalId
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ServicePrincipalClientID'
      SecretContentType: 'Deployment'
    }
  }

  
  param ServicePrincipalSec string
  module kvSecretClientSec 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-ADFClientSec-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: ServicePrincipalSec
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ServicePrincipalClientSecret'
      SecretContentType: 'Deployment'
    }
  }

  module kvSecretADFShir 'Azure Resources/Key Vault Secret.bicep' = {
    name: 'KeyVaultSecretDeploy-ADFShir-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: 'POFIntegrationRuntime'
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'ADFIntegrationRuntimeName'
      SecretContentType: 'Deployment'
    }
  }


  module kvSecretSSASServerName 'Azure Resources/Key Vault Secret.bicep' = [for instance in DeployAnalysisServices ? AnalysisServicesInstances : range(0, 0) : {
    name: 'KeyVaultSecretDeploy-${instance.InstanceName}-${UniqueName}'
    dependsOn: [
      kv
    ]
    params: {
      SecretValue: instance.InstanceName
      KeyVaultName: kv.outputs.KeyVaultName
      SecretName: 'SSASServerName'
      SecretContentType: 'Deployment'
      }
    }]

    module kvSecretSSASSourceConString 'Azure Resources/Key Vault Secret.bicep' = {
      name: 'KeyVaultSecretDeploy-SSASSourceConString-${UniqueName}'
      dependsOn: [
        kv
      ]
      params: {
        SecretValue: 'provider=MSOLEDBSQL;Data Source=${SqlServerName}.database.windows.net;Initial Catalog=${SqlDatabases.DatabaseName};Persist Security Info=True;User ID=${SqlServerAdminUserName};Password=${SqlServerAdminPassword};'
        KeyVaultName: kv.outputs.KeyVaultName
        SecretName: 'SSASSourceConnectionString'
        SecretContentType: 'Deployment'
        }
      }

    module kvSecretSSASConString 'Azure Resources/Key Vault Secret.bicep' = [for instance in DeployAnalysisServices ? AnalysisServicesInstances : range(0, 0) : {
        name: 'KeyVaultSecretDeploy-${instance.InstanceName}SCS-${UniqueName}'
        dependsOn: [
          kv
        ]
        params: {
          SecretValue: 'Provider=MSOLAP;Data Source=asazure://${Location}.asazure.windows.net/${instance.InstanceName};User ID=app:${ServicePrincipalId}@${TenantId};Password=${ServicePrincipalSec};Persist Security Info=True;Impersonation Level=Impersonate'
          KeyVaultName: kv.outputs.KeyVaultName
          SecretName: 'SSASConnectionString'
          SecretContentType: 'Deployment'
          }
        }]
        

        module kvSecretConStringDeployment 'Azure Resources/Key Vault Secret.bicep' = {
          name: 'KeyVaultSecretDeploy-ConStringDeployment-${UniqueName}'
          dependsOn: [
            kv
          ]
          params: {
            SecretValue: 'Server=sql-${ProjectName}-${EnvironmentVariable}.database.windows.net;initial catalog=${SqlDatabases.DatabaseName};User ID=${SqlServerAdminUserName};Password=${SqlServerAdminPassword};Integrated Security=False;'
            KeyVaultName: kv.outputs.KeyVaultName
            SecretName: 'ConnectionString-Deployment'
            SecretContentType: 'ConnectionString'
          }
        }

        module kvSecretSQLUsername 'Azure Resources/Key Vault Secret.bicep' = {
          name: 'KeyVaultSecretDeploy-SQLUsername-${UniqueName}'
          dependsOn: [
            kv
          ]
          params: {
            SecretValue: SqlServerAdminUserName
            KeyVaultName: kv.outputs.KeyVaultName
            SecretName: 'SQLUserName'
            SecretContentType: 'Deployment'
          }
        }

        module kvSecretSQLUserPassword 'Azure Resources/Key Vault Secret.bicep' = {
          name: 'KeyVaultSecretDeploy-SQLUserPassword-${UniqueName}'
          dependsOn: [
            kv
          ]
          params: {
            SecretValue: SqlServerAdminPassword  
            KeyVaultName: kv.outputs.KeyVaultName
            SecretName: 'SQLUserPassword'
            SecretContentType: 'Deployment'
          }
        }
